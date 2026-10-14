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
//!
//! # References
//!
//! - [XSETTINGS specification][spec] — Owen Taylor's spec, v0.5. The
//!   [`_XSETTINGS_SETTINGS` format][fmt] section is the authority for the blob
//!   parsed in [`xsettings`]; the [manager behavior][mgr] section covers owning
//!   the selection and bumping the serial.
//! - [X Window System Protocol][xproto] — the core protocol. The requests used
//!   here are `InternAtom`, `GetSelectionOwner`, `GetProperty` and
//!   `ChangeProperty` (see section 9, Requests).
//! - [x11rb documentation][x11rb] — the client library, in particular the
//!   [cookie module][cookie] for how a request becomes a reply.
//! - [xwayland-satellite][satellite] — the usual owner of `_XSETTINGS_S0` on
//!   Wayland, and the reason unrelated keys must survive a rewrite.
//! - [xsettingsd][xsettingsd] — a standalone C++ XSETTINGS manager, useful as a
//!   reference implementation and for its `dump_xsettings` tool.
//!
//! [spec]: https://dueno.pages.freedesktop.org/xdg-specs/xsettings-spec/latest/
//! [fmt]: https://dueno.pages.freedesktop.org/xdg-specs/xsettings-spec/latest/ar01s04.html
//! [mgr]: https://dueno.pages.freedesktop.org/xdg-specs/xsettings-spec/latest/ar01s05.html
//! [xproto]: https://xorg.freedesktop.org/archive/current/doc/xproto/x11protocol.html
//! [x11rb]: https://docs.rs/x11rb/0.14.0/x11rb/
//! [cookie]: https://docs.rs/x11rb/0.14.0/x11rb/cookie/index.html
//! [satellite]: https://github.com/Supreeeme/xwayland-satellite
//! [xsettingsd]: https://codeberg.org/derat/xsettingsd

mod cli;
mod error;
mod xsettings;

use palc::Parser as _;
use snafu::ResultExt as _;
use x11rb::protocol::xproto::{AtomEnum, ConnectionExt as _, PropMode};
use x11rb::rust_connection::RustConnection;
use x11rb::wrapper::ConnectionExt as _;

use crate::cli::Cli;
use crate::error::{ConnectSnafu, NoOwnerSnafu, ReplySnafu, Result, SendRequestSnafu};
use crate::xsettings::XSettings;

/// Intern an atom by name, awaiting the reply.
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

    let selection = atom(&conn, "_XSETTINGS_S0")?;
    let property = atom(&conn, "_XSETTINGS_SETTINGS")?;

    let owner = conn
        .get_selection_owner(selection)
        .context(SendRequestSnafu {
            request: "get_selection_owner",
        })?
        .reply()
        .context(ReplySnafu {
            request: "get_selection_owner",
        })?
        .owner;

    if owner == x11rb::NONE {
        return NoOwnerSnafu.fail();
    }

    // Start from the published blob so the keys we do not own (the satellite's
    // DPI and scaling entries) survive our write.
    let reply = conn
        .get_property(false, owner, property, AtomEnum::ANY, 0, 1 << 20)
        .context(SendRequestSnafu {
            request: "get_property",
        })?
        .reply()
        .context(ReplySnafu {
            request: "get_property",
        })?;

    let mut settings = if reply.value.is_empty() {
        XSettings::empty()
    } else {
        XSettings::parse(&reply.value)?
    };

    for (name, value) in cli.keys() {
        settings.set(name, value);
    }
    let serial = settings.bump();

    conn.change_property8(
        PropMode::REPLACE,
        owner,
        property,
        property,
        &settings.blob(),
    )
    .context(SendRequestSnafu {
        request: "change_property8",
    })?
    .check()
    .context(ReplySnafu {
        request: "change_property8",
    })?;

    println!(
        "xsettings-theme: serial={serial} entries={} theme={}",
        settings.len(),
        cli.theme()
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
