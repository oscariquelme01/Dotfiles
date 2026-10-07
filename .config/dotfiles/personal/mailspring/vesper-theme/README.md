# Vesper Theme for Mailspring

**Vesper** is my fork of the
[Sparky Mailspring Theme](https://github.com/siniux/Sparky-Mailspring-Theme),
adapted with a palette inspired by
[Vesper](https://github.com/raunofreiberg/vesper) by Rauno Freiberg.

The sidebar, thread list, reading pane, composer, menus, and preferences use
near-black surfaces with peach accents and mint highlights.

## Install

1. Open Mailspring and choose **Edit → Install Theme…** from the menu bar.
2. Select this folder (the one containing `package.json`).
3. Choose **Vesper** in **Preferences → Appearance** if it isn't selected automatically.

## Palette

| Role | Color |
| --- | --- |
| Background | `#101010` |
| Message / composer surface | `#161616` |
| Inputs | `#1C1C1C` |
| Selection | `#232323` |
| Text | `#FFFFFF` |
| Secondary text | `#A0A0A0` |
| Accent | `#FFC799` |
| Mint / archive | `#99FFE4` |
| Error / trash | `#FF8080` |

Edit `styles/sparky-variables.less` to customize the palette.
`styles/ui-variables.less` applies it to Mailspring's shared controls and plugins.
`styles/email-frame.less` adapts received email text and backgrounds to dark mode,
including HTML messages, while preserving image colors. These display styles
do not change the message itself or the colors sent in outgoing emails.

UI styles are imported by `styles/theme.less` from `styles/components/`.
There must not be a `styles/index.less`: Mailspring would load only that file
and skip the email-frame stylesheet. When updating an existing installation,
replace the old theme folder rather than merging files, then restart Mailspring.

The decorative inbox-zero artwork and custom window controls are hidden.

The images in `screenshot/` show the original Sparky theme, not this Vesper adaptation.

## Credits

- Original layout and MIT license: Sparky by siniux.
- Palette: Vesper by Rauno Freiberg.
- This fork retains Sparky's MIT license (see `LICENSE`).
