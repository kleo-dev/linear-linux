const { app, BrowserWindow, session, globalShortcut } = require('electron');
const fs = require('fs');
const path = require('path');

let stateFilePath;

const loadWindowState = () => {
    if (!stateFilePath) return {};
    try {
        const raw = fs.readFileSync(stateFilePath, 'utf8');
        const parsed = JSON.parse(raw);
        const { width, height, x, y } = parsed;
        if (Number.isFinite(width) && Number.isFinite(height)) {
            return {
                width,
                height,
                x: Number.isFinite(x) ? x : undefined,
                y: Number.isFinite(y) ? y : undefined,
            };
        }
    } catch (_) {
        // Ignore malformed or missing state and fall back to defaults.
    }
    return {};
};

const saveWindowState = (bounds) => {
    if (!stateFilePath || !bounds) return;
    try {
        fs.mkdirSync(path.dirname(stateFilePath), { recursive: true });
        fs.writeFileSync(stateFilePath, JSON.stringify(bounds), 'utf8');
    } catch (_) {
        // Persisting state is best-effort; ignore write failures.
    }
};

const createWindow = () => {
    let state = {};
    const focusedWindow = BrowserWindow.getFocusedWindow();

    if (focusedWindow) {
        const bounds = focusedWindow.getBounds();
        state = {
            width: bounds.width,
            height: bounds.height,
            x: bounds.x + 30,
            y: bounds.y + 30
        };
    } else {
        state = loadWindowState();
    }

    const windowOptions = {
        width: state.width || 800,
        height: state.height || 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
        },
    };

    if (Number.isFinite(state.x) && Number.isFinite(state.y)) {
        windowOptions.x = state.x;
        windowOptions.y = state.y;
    }

    const win = new BrowserWindow(windowOptions);
    win.setMenu(null);
    win.loadURL('https://linear.app/login');

    win.on('close', () => {
        saveWindowState(win.getBounds());
    });
};

app.whenReady().then(() => {
    stateFilePath = path.join(app.getPath('userData'), 'window-state.json');

    session.defaultSession.setPermissionRequestHandler((_, permission, callback, details) => {
        const origin = details?.requestingUrl || '';
        const isLinear = origin.startsWith('https://linear.app');
        if (permission === 'notifications' && isLinear) {
            return callback(true);
        }
        return callback(false);
    });

    createWindow();

    app.on('browser-window-focus', () => {
        globalShortcut.register('CommandOrControl+Shift+N', createWindow);
    });

    app.on('browser-window-blur', () => {
        globalShortcut.unregister('CommandOrControl+Shift+N');
    });

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
