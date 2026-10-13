//! Set the theme keys in the XSETTINGS property, preserving all other entries.
//!
//! The property lives on whichever window owns the `_XSETTINGS_S0` selection
//! (xwayland-satellite, normally — it takes the selection to publish DPI).
//! Clients read that property and get notified via PropertyNotify, so rewriting
//! it rethemes every running X11 GTK app with no restart.
//!
//! Existing entries are preserved on purpose: GTK deletes any setting that
//! disappears from the blob, so dropping the satellite's DPI keys would break
//! HiDPI scaling on X11.

use palc::Parser;
use snafu::{ResultExt, Snafu};
use x11rb::connection::Connection;
use x11rb::protocol::xproto::{AtomEnum, ConnectionExt as _, PropMode};
use x11rb::rust_connection::RustConnection;
use x11rb::wrapper::ConnectionExt as _;

/// Keys this helper owns. Any existing entry with one of these names is replaced.
const MANAGED: [&str; 4] = [
    "Net/ThemeName",
    "Net/IconThemeName",
    "Gtk/CursorThemeName",
    "Gtk/FontName",
];

const KIND_INTEGER: u8 = 0;
const KIND_STRING: u8 = 1;

/// Write light/dark theme keys into the XSETTINGS property.
#[derive(Debug, Parser)]
#[command(name = "xsettings-theme")]
struct Cli {
    /// GTK theme name to advertise (e.g. adw-gtk3 or adw-gtk3-dark)
    #[arg(long, default_value = "adw-gtk3-dark")]
    theme: String,

    /// Icon theme name
    #[arg(long, default_value = "Adwaita")]
    icon_theme: String,

    /// Cursor theme name
    #[arg(long, default_value = "catppuccin-mocha-dark-cursors")]
    cursor_theme: String,

    /// Font name, as `Family Size`
    #[arg(long, default_value = "Adwaita Sans 11")]
    font: String,
}

#[derive(Debug, Snafu)]
enum Error {
    #[snafu(display("cannot connect to the X display"))]
    Connect { source: x11rb::errors::ConnectError },

    #[snafu(display("no _XSETTINGS_S0 owner; no XSETTINGS manager is running"))]
    NoOwner,

    // x11rb reports sending a request and awaiting its reply as two different
    // error types, so each X call needs both halves.
    #[snafu(display("sending a request to the X server failed"))]
    SendRequest {
        request: &'static str,
        source: x11rb::errors::ConnectionError,
    },

    #[snafu(display("the X server rejected `{request}`"))]
    Reply {
        request: &'static str,
        source: x11rb::errors::ReplyError,
    },

    #[snafu(display("the existing XSETTINGS property is malformed"))]
    MalformedProperty,

    #[snafu(display("flushing the X connection failed"))]
    Flush {
        source: x11rb::errors::ConnectionError,
    },
}

type Result<T, E = Error> = std::result::Result<T, E>;

struct Entry {
    name: String,
    kind: u8,
    /// Raw value bytes: 4 bytes for an integer, the payload for a string.
    value: Vec<u8>,
}

#[inline]
fn pad4(n: usize) -> usize {
    (4 - (n % 4)) % 4
}

#[inline]
fn rd32(b: &[u8], off: usize, le: bool) -> u32 {
    let s = [b[off], b[off + 1], b[off + 2], b[off + 3]];
    if le {
        u32::from_le_bytes(s)
    } else {
        u32::from_be_bytes(s)
    }
}

/// Parse a `_XSETTINGS_SETTINGS` blob into its serial and entries.
fn parse(b: &[u8]) -> Result<(u32, Vec<Entry>)> {
    if b.len() < 12 {
        return MalformedPropertySnafu.fail();
    }
    let le = b[0] == 0;
    let serial = rd32(b, 4, le);
    let count = rd32(b, 8, le);
    let mut pos = 12usize;
    let mut out = Vec::new();

    for _ in 0..count {
        if pos + 4 > b.len() {
            return MalformedPropertySnafu.fail();
        }
        let kind = b[pos];
        let nlen = u16::from_le_bytes([b[pos + 2], b[pos + 3]]) as usize;
        pos += 4;

        if pos + nlen > b.len() {
            return MalformedPropertySnafu.fail();
        }
        let name = String::from_utf8_lossy(&b[pos..pos + nlen]).into_owned();
        pos += nlen + pad4(nlen);

        if pos + 4 > b.len() {
            return MalformedPropertySnafu.fail();
        }
        pos += 4; // per-entry change serial; GTK ignores it

        let value = match kind {
            KIND_INTEGER => {
                if pos + 4 > b.len() {
                    return MalformedPropertySnafu.fail();
                }
                let v = b[pos..pos + 4].to_vec();
                pos += 4;
                v
            }
            KIND_STRING => {
                if pos + 4 > b.len() {
                    return MalformedPropertySnafu.fail();
                }
                let sl = rd32(b, pos, le) as usize;
                pos += 4;
                if pos + sl > b.len() {
                    return MalformedPropertySnafu.fail();
                }
                let v = b[pos..pos + sl].to_vec();
                pos += sl + pad4(sl);
                v
            }
            // COLOR and anything unknown: refuse rather than corrupt the blob.
            _ => return MalformedPropertySnafu.fail(),
        };

        out.push(Entry { name, kind, value });
    }

    Ok((serial, out))
}

/// Serialize entries back into a blob, little-endian.
fn emit(serial: u32, entries: &[Entry]) -> Vec<u8> {
    let mut o = Vec::new();
    o.extend_from_slice(&[0, 0, 0, 0]); // LSBFirst + 3 unused bytes
    o.extend_from_slice(&serial.to_le_bytes());
    o.extend_from_slice(&(entries.len() as u32).to_le_bytes());

    for e in entries {
        o.push(e.kind);
        o.push(0);
        o.extend_from_slice(&(e.name.len() as u16).to_le_bytes());
        o.extend_from_slice(e.name.as_bytes());
        o.resize(o.len() + pad4(e.name.len()), 0);
        o.extend_from_slice(&serial.to_le_bytes());

        if e.kind == KIND_STRING {
            o.extend_from_slice(&(e.value.len() as u32).to_le_bytes());
            o.extend_from_slice(&e.value);
            o.resize(o.len() + pad4(e.value.len()), 0);
        } else {
            o.extend_from_slice(&e.value);
        }
    }

    o
}

fn str_entry(name: &str, value: &str) -> Entry {
    Entry {
        name: name.to_string(),
        kind: KIND_STRING,
        value: value.as_bytes().to_vec(),
    }
}

fn atom(conn: &RustConnection, name: &'static str) -> Result<u32> {
    Ok(conn
        .intern_atom(false, name.as_bytes())
        .context(SendRequestSnafu {
            request: "intern_atom",
        })?
        .reply()
        .context(ReplySnafu {
            request: "intern_atom",
        })?
        .atom)
}

fn run(cli: &Cli) -> Result<()> {
    let (conn, _screen_num) = x11rb::connect(None).context(ConnectSnafu)?;

    let sel = atom(&conn, "_XSETTINGS_S0")?;
    let prop = atom(&conn, "_XSETTINGS_SETTINGS")?;

    let win = conn
        .get_selection_owner(sel)
        .context(SendRequestSnafu {
            request: "get_selection_owner",
        })?
        .reply()
        .context(ReplySnafu {
            request: "get_selection_owner",
        })?
        .owner;

    if win == x11rb::NONE {
        return NoOwnerSnafu.fail();
    }

    // Pull the current blob so existing keys (DPI, scale) survive our write.
    let reply = conn
        .get_property(false, win, prop, AtomEnum::ANY, 0, 1 << 20)
        .context(SendRequestSnafu {
            request: "get_property",
        })?
        .reply()
        .context(ReplySnafu {
            request: "get_property",
        })?;

    let (serial, mut entries) = if reply.value.is_empty() {
        (1, Vec::new())
    } else {
        parse(&reply.value)?
    };

    entries.retain(|e| !MANAGED.contains(&e.name.as_str()));
    entries.push(str_entry("Net/ThemeName", &cli.theme));
    entries.push(str_entry("Net/IconThemeName", &cli.icon_theme));
    entries.push(str_entry("Gtk/CursorThemeName", &cli.cursor_theme));
    entries.push(str_entry("Gtk/FontName", &cli.font));

    let next_serial = serial.wrapping_add(1).max(1);
    let blob = emit(next_serial, &entries);

    conn.change_property8(PropMode::REPLACE, win, prop, prop, &blob)
        .context(SendRequestSnafu {
            request: "change_property8",
        })?
        .check()
        .context(ReplySnafu {
            request: "change_property8",
        })?;
    conn.flush().context(FlushSnafu)?;

    println!(
        "xsettings-theme: serial={next_serial} entries={} theme={}",
        entries.len(),
        cli.theme
    );
    Ok(())
}

fn main() {
    let cli = Cli::parse();
    if let Err(err) = run(&cli) {
        eprintln!("xsettings-theme: {err}");
        std::process::exit(1);
    }
}
