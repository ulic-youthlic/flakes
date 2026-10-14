//! The error type shared by the X11 calls and the XSETTINGS codec.

use snafu::Snafu;

// The context selectors this derives (`SendRequestSnafu` and friends) are
// generated with the variant's visibility, which is private in this module, so
// ask for the crate-wide one that main.rs needs to call them.
#[derive(Debug, Snafu)]
#[snafu(visibility(pub(crate)))]
pub(crate) enum Error {
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
}

pub(crate) type Result<T, E = Error> = std::result::Result<T, E>;
