//! The command line: which theme keys to advertise and what to set them to.

use palc::Parser;

/// Write light/dark theme keys into the XSETTINGS property.
#[derive(Debug, Parser)]
#[command(name = "xsettings-theme")]
pub(crate) struct Cli {
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

impl Cli {
    /// The keys this helper owns, each paired with the value to advertise.
    ///
    /// Any entry under one of these names is replaced; every other name in the
    /// blob is left alone.
    pub(crate) fn keys(&self) -> [(&'static str, &str); 4] {
        [
            ("Net/ThemeName", &self.theme),
            ("Net/IconThemeName", &self.icon_theme),
            ("Gtk/CursorThemeName", &self.cursor_theme),
            ("Gtk/FontName", &self.font),
        ]
    }

    /// The theme name, for the one-line summary printed on success.
    pub(crate) fn theme(&self) -> &str {
        &self.theme
    }
}
