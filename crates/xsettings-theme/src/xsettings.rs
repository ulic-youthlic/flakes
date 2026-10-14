//! The `_XSETTINGS_SETTINGS` property: its wire format, and the types that
//! read and write it.
//!
//! The blob is a 12-byte header followed by a count of entries:
//!
//! ```text
//!  0      1            4              8                12
//! +------+------------+--------------+----------------+=========
//! | byte |  unused    | serial (u32) |  count (u32)   | entries
//! | order|   3 bytes  |              |                |  x count
//! +------+------------+--------------+----------------+=========
//!    0 = LSBFirst                        number of entries
//!    1 = MSBFirst                        that follow
//! ```
//!
//! Every integer — the serial, the count, and each length and value in the
//! entries — is written in the byte order that leading byte selects, so
//! [`ByteOrder`] is read from offset 0 and governs the rest of the parse. See
//! [`Entry`] and [`Value`] for the per-entry layout.

use crate::error::{Error, Result};

/// The kind of a value, as it appears in the first byte of an entry.
///
/// Only the kinds this helper round-trips are listed. XSETTINGS also defines a
/// COLOR kind (2), which is refused at parse time rather than modelled: writing
/// one we cannot decode would corrupt the blob for every client reading it.
///
/// `repr(u8)`, so the discriminant *is* the wire byte.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
enum Kind {
    /// A signed 32-bit integer.
    Integer = 0,
    /// A UTF-8 string.
    Text = 1,
}

impl TryFrom<u8> for Kind {
    type Error = Error;

    /// Everything outside the supported set is a blob we should not touch.
    fn try_from(byte: u8) -> Result<Self> {
        match byte {
            0 => Ok(Self::Integer),
            1 => Ok(Self::Text),
            _ => Err(Error::MalformedProperty),
        }
    }
}

impl From<Kind> for u8 {
    fn from(kind: Kind) -> Self {
        kind as u8
    }
}

/// The byte order the integers of a blob are written in: header byte 0 is 0 for
/// little-endian, 1 for big-endian.
///
/// Held as a value rather than the raw `bool` this used to thread through as
/// `le`, so the decode and encode sides read as a matched pair.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ByteOrder {
    Little,
    Big,
}

impl ByteOrder {
    fn from_flag(flag: u8) -> Self {
        if flag == 0 { Self::Little } else { Self::Big }
    }

    fn flag(self) -> u8 {
        match self {
            Self::Little => 0,
            Self::Big => 1,
        }
    }

    fn decode_u16(self, bytes: [u8; 2]) -> u16 {
        match self {
            Self::Little => u16::from_le_bytes(bytes),
            Self::Big => u16::from_be_bytes(bytes),
        }
    }

    fn decode_u32(self, bytes: [u8; 4]) -> u32 {
        match self {
            Self::Little => u32::from_le_bytes(bytes),
            Self::Big => u32::from_be_bytes(bytes),
        }
    }

    fn encode_u16(self, value: u16) -> [u8; 2] {
        match self {
            Self::Little => value.to_le_bytes(),
            Self::Big => value.to_be_bytes(),
        }
    }

    fn encode_u32(self, value: u32) -> [u8; 4] {
        match self {
            Self::Little => value.to_le_bytes(),
            Self::Big => value.to_be_bytes(),
        }
    }
}

/// Zero bytes needed to round a field of `len` bytes up to four.
#[inline]
fn pad4(len: usize) -> usize {
    len.next_multiple_of(4) - len
}

/// A front-to-back cursor over a property blob.
///
/// Every read consumes the bytes it returns, so the position is whatever is
/// left of the slice: there is no offset to keep in step with the reads by
/// hand, and reading past the end is an error rather than a panic.
struct Reader<'a> {
    rest: &'a [u8],
}

impl<'a> Reader<'a> {
    fn new(blob: &'a [u8]) -> Self {
        Self { rest: blob }
    }

    /// Consume `len` bytes.
    fn take(&mut self, len: usize) -> Result<&'a [u8]> {
        let rest: &'a [u8] = self.rest;
        let (head, tail) = rest.split_at_checked(len).ok_or(Error::MalformedProperty)?;
        self.rest = tail;
        Ok(head)
    }

    /// Consume `N` bytes as a fixed-size array.
    fn array<const N: usize>(&mut self) -> Result<[u8; N]> {
        let rest: &'a [u8] = self.rest;
        let (head, tail) = rest
            .split_first_chunk::<N>()
            .ok_or(Error::MalformedProperty)?;
        self.rest = tail;
        Ok(*head)
    }

    fn u8(&mut self) -> Result<u8> {
        Ok(self.array::<1>()?[0])
    }

    fn u16(&mut self, order: ByteOrder) -> Result<u16> {
        Ok(order.decode_u16(self.array()?))
    }

    fn u32(&mut self, order: ByteOrder) -> Result<u32> {
        Ok(order.decode_u32(self.array()?))
    }

    /// Consume `len` bytes and drop them — the padding to the next four-byte
    /// boundary.
    fn skip(&mut self, len: usize) -> Result<()> {
        self.take(len).map(drop)
    }

    /// Consume a UTF-8 string of `len` bytes plus the padding after it.
    ///
    /// Names and text values are borrowed verbatim from other clients, so this
    /// rejects anything that is not UTF-8 rather than replacing the bad bytes:
    /// a replacement character would change the length the string is written
    /// back out with, shifting every entry that follows it.
    fn text(&mut self, len: usize) -> Result<String> {
        let bytes = self.take(len)?;
        self.skip(pad4(len))?;
        str::from_utf8(bytes)
            .map(str::to_owned)
            .map_err(|_| Error::MalformedProperty)
    }
}

/// One key of the property: a name and the value under it.
///
/// One entry, as it sits in the blob:
///
/// ```text
///  0        1        2         4                4+n      +4         +8
/// +--------+--------+---------+================+--------+----------+========
/// |  kind  | unused | n       |  name (n bytes)| padding|  serial  |  value
/// |   u8   |   u8   |  u16    |  utf8          | pad4(n)|   u32    |   ...
/// +--------+--------+---------+================+--------+----------+========
///                                                          (per-entry
///                                                           change serial)
/// ```
///
/// `kind` is the leading byte of the value's own layout (see [`Value`]), and
/// `n` is a `u16` — so a name is capped at 65535 bytes. Both the name and the
/// value are padded so the next field starts on a 4-byte boundary.
#[derive(Debug)]
struct Entry {
    name: String,
    value: Value,
}

impl Entry {
    /// Consume one entry: `[kind, unused][u16 name length][name][padding]
    /// [change serial][value]`.
    fn read(reader: &mut Reader<'_>, order: ByteOrder) -> Result<Self> {
        let kind = Kind::try_from(reader.u8()?)?;
        reader.skip(1)?; // unused

        let name_len = reader.u16(order)? as usize;
        let name = reader.text(name_len)?;

        // Per-entry change serial. GTK ignores it, and everything we write out
        // carries the blob's serial, so there is nothing to keep here.
        reader.u32(order)?;

        Ok(Self {
            name,
            value: Value::read(reader, order, kind)?,
        })
    }

    /// Append this entry to `out`.
    fn write(&self, out: &mut Vec<u8>, order: ByteOrder, serial: u32) {
        out.push(self.value.kind().into());
        out.push(0); // unused
        out.extend_from_slice(&order.encode_u16(self.name.len() as u16));
        out.extend_from_slice(self.name.as_bytes());
        out.resize(out.len() + pad4(self.name.len()), 0);
        out.extend_from_slice(&order.encode_u32(serial));

        match &self.value {
            Value::Integer(value) => out.extend_from_slice(&order.encode_u32(*value as u32)),
            Value::Text(text) => {
                out.extend_from_slice(&order.encode_u32(text.len() as u32));
                out.extend_from_slice(text.as_bytes());
                out.resize(out.len() + pad4(text.len()), 0);
            }
        }
    }
}

/// The value under a key.
///
/// The payload following [`Entry`]'s header, chosen by the entry's `kind`
/// byte. The two variants are laid out differently on the wire — one is a
/// fixed 4 bytes, the other is length-prefixed and padded:
///
/// ```text
/// kind 0 — Integer
/// +------------------+
/// |      i32  (4)    |          raw 32-bit value, no padding
/// +------------------+
///
/// kind 1 — Text
///  0              4                4+m      +4
/// +---------------+================+--------+
/// |   m  (u32)    |  utf8 (m bytes)| padding|
/// +---------------+================+--------+
///   length prefix                   pad4(m)
/// ```
///
/// `Integer` carries a signed `i32` written as four raw bytes, so a negative
/// value is the two's-complement pattern rather than a sign-and-magnitude one.
/// `Text` is a `u32` length — unlike `Entry`'s `u16` name length — followed by
/// the bytes and the same 4-byte alignment.
///
/// `kind` itself belongs to the entry, not here: it is the first byte of
/// `Entry`'s header, which is why `read` takes it as an argument rather than
/// reading it off this type.
#[derive(Debug)]
pub(crate) enum Value {
    Integer(i32),
    Text(String),
}

impl Value {
    /// Read the payload for an already-decoded `kind`.
    ///
    /// The match is exhaustive on purpose: a kind added to `Kind` fails to
    /// compile here rather than falling into a `_` arm.
    fn read(reader: &mut Reader<'_>, order: ByteOrder, kind: Kind) -> Result<Self> {
        match kind {
            Kind::Integer => Ok(Self::Integer(reader.u32(order)? as i32)),
            Kind::Text => {
                let len = reader.u32(order)? as usize;
                Ok(Self::Text(reader.text(len)?))
            }
        }
    }

    /// The kind byte this value goes out with.
    fn kind(&self) -> Kind {
        match self {
            Self::Integer(_) => Kind::Integer,
            Self::Text(_) => Kind::Text,
        }
    }
}

impl From<&str> for Value {
    fn from(text: &str) -> Self {
        Self::Text(text.to_string())
    }
}

/// The `_XSETTINGS_SETTINGS` property, whole.
///
/// Clients retheme when the serial moves, and they drop any setting missing
/// from the blob, so this type round-trips everything it did not set itself.
/// The layout is described in the [module docs](self), and the serial is
/// bumped on every write; clients treat a change as "re-read me".
#[derive(Debug)]
pub(crate) struct XSettings {
    order: ByteOrder,
    serial: u32,
    entries: Vec<Entry>,
}

impl XSettings {
    /// The property of an owner that has not published one yet: serial 1, so
    /// the first write is serial 2.
    pub(crate) fn empty() -> Self {
        Self {
            order: ByteOrder::Little,
            serial: 1,
            entries: Vec::new(),
        }
    }

    /// Parse a blob, leaving it be if anything in it is malformed.
    pub(crate) fn parse(blob: &[u8]) -> Result<Self> {
        let mut reader = Reader::new(blob);
        let order = ByteOrder::from_flag(reader.u8()?);
        reader.skip(3)?; // unused
        let serial = reader.u32(order)?;
        let count = reader.u32(order)?;

        let entries = (0..count)
            .map(|_| Entry::read(&mut reader, order))
            .collect::<Result<Vec<_>>>()?;

        Ok(Self {
            order,
            serial,
            entries,
        })
    }

    /// Render back into a property blob.
    pub(crate) fn blob(&self) -> Vec<u8> {
        let mut out = Vec::new();
        out.push(self.order.flag());
        out.extend_from_slice(&[0; 3]); // unused
        out.extend_from_slice(&self.order.encode_u32(self.serial));
        out.extend_from_slice(&self.order.encode_u32(self.entries.len() as u32));

        for entry in &self.entries {
            entry.write(&mut out, self.order, self.serial);
        }
        out
    }

    /// How many entries the property holds, for the summary line.
    pub(crate) fn len(&self) -> usize {
        self.entries.len()
    }

    /// Replace `name` where it stands, or append it if it is new.
    ///
    /// Replacing in place leaves the blob in the order its owner published,
    /// rather than reshuffling it with our keys at the end.
    pub(crate) fn set(&mut self, name: &str, value: impl Into<Value>) {
        let value = value.into();
        match self.entries.iter_mut().find(|entry| entry.name == name) {
            Some(entry) => entry.value = value,
            None => self.entries.push(Entry {
                name: name.to_string(),
                value,
            }),
        }
    }

    /// Advance the serial. Clients act on a change, so never write 0.
    pub(crate) fn bump(&mut self) -> u32 {
        self.serial = self.serial.wrapping_add(1).max(1);
        self.serial
    }
}
