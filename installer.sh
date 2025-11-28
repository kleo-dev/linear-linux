#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:-0.2.3}"
APPIMAGE_URL="${APPIMAGE_URL:-https://github.com/kleo-dev/linear-linux/releases/download/v${VERSION}/linear-linux-${VERSION}.AppImage}"
INSTALL_ROOT="${INSTALL_ROOT:-/opt}"
INSTALL_DIR="${INSTALL_ROOT}/linear-linux-${VERSION}"
WRAPPER_PATH="/usr/local/bin/linear"
DESKTOP_PATH="/usr/share/applications/linear.desktop"
APP_NAME="Linear"
APP_DIR="${INSTALL_DIR}/squashfs-root"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_SVG="${SCRIPT_DIR}/assets/linear-icon.svg"
ICON_PNG="${SCRIPT_DIR}/assets/linear-app-icon.png"

if [[ ! -f "${ICON_SVG}" || ! -f "${ICON_PNG}" ]]; then
  echo "Icon assets missing. Expected ${ICON_SVG} and ${ICON_PNG}." >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading Linear AppImage ${VERSION}..."
curl -fsSL "${APPIMAGE_URL}" -o "${tmpdir}/linear.AppImage"
chmod +x "${tmpdir}/linear.AppImage"

echo "Installing to ${INSTALL_DIR}..."
sudo mkdir -p "${INSTALL_DIR}"
sudo cp "${tmpdir}/linear.AppImage" "${INSTALL_DIR}/linear.AppImage"
sudo chmod +x "${INSTALL_DIR}/linear.AppImage"
sudo bash -lc "cd \"${INSTALL_DIR}\" && ./linear.AppImage --appimage-extract >/dev/null"
sudo chmod -R a+rX "${APP_DIR}"

echo "Configuring sandbox helper..."
sudo chown root:root "${APP_DIR}/chrome-sandbox"
sudo chmod 4755 "${APP_DIR}/chrome-sandbox"

echo "Creating launch wrapper at ${WRAPPER_PATH}..."
sudo tee "${WRAPPER_PATH}" >/dev/null <<EOF
#!/usr/bin/env bash
export CHROME_DEVEL_SANDBOX="${APP_DIR}/chrome-sandbox"
exec "${APP_DIR}/AppRun" "\$@"
EOF
sudo chmod 755 "${WRAPPER_PATH}"

echo "Installing desktop entry..."
sudo tee "${DESKTOP_PATH}" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=${APP_NAME}
Exec=${WRAPPER_PATH} %U
Icon=linear
Terminal=false
Categories=Utility;
StartupWMClass=linear-linux
EOF

echo "Installing icons..."
sudo install -Dm644 "${ICON_SVG}" /usr/share/icons/hicolor/scalable/apps/linear.svg
sudo install -Dm644 "${ICON_PNG}" /usr/share/icons/hicolor/512x512/apps/linear.png
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor || true

echo "Linear ${VERSION} installed. Launch with: ${WRAPPER_PATH}"
