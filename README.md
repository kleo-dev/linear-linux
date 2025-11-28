<p align="center">
<img alt="GH-rel ver" src="icon.png" width="100px">
<h1 align="center">Linear for linux</h1>

<p align="center">
A linux port of <a href="https://linear.app/">linear.app</a>
</p>

<p align="center">
<img alt="GH-rel ver" src="https://img.shields.io/github/v/release/kleo-dev/linear-linux?color=%23f5304c">
</p>

# Install
Requires `sudo` (for sandbox helper, desktop entry, and icons).

```bash
wget -qO- https://raw.githubusercontent.com/kleo-dev/linear-linux/refs/heads/master/installer.sh | bash
```

The installer:
- Downloads the AppImage, extracts it under `/opt/linear-linux-<version>`, and wires up the `chrome-sandbox` helper correctly.
- Installs a wrapper at `/usr/local/bin/linear`, a desktop entry, and the Linear icon into the system icon cache.
- Accepts overrides: `VERSION=0.2.1 APPIMAGE_URL=<url> INSTALL_ROOT=/opt ./installer.sh`

Development:
- `npm start` launches Electron with sandbox disabled for local runs (packaged builds use the proper setuid helper).
- `npm run build` produces an AppImage that bundles the Linear brand assets for the desktop icon.

# Having an issue?
Describe your issue [here](https://github.com/kleo-dev/linear-linux/issues)
