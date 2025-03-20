const { app, BrowserWindow } = require('electron');

let mainWindow;

app.whenReady().then(() => {
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    mainWindow.setMenu(null);

    mainWindow.loadURL('https://linear.app/login');

    app.on('window-all-closed', () => {
        if (process.platform !== 'darwin') {
            app.quit();
        }
    });
});
