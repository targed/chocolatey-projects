# Grayjay Package Parameters

This document describes the available package parameters for customizing the Grayjay installation.

## Available Parameters

### `/NoPortable`
- **Description**: Disables portable mode by removing the portable marker file
- **Effect**: Grayjay will store user data in `%APPDATA%\Grayjay` instead of the installation directory
- **Use Case**: Recommended for standard installations where you want user data stored in the user profile

### `/NoShortcut`
- **Description**: Prevents creation of a desktop shortcut
- **Effect**: No desktop shortcut will be created during installation
- **Use Case**: Useful for automated deployments or when you don't want desktop clutter

### `/KeepAppData`
- **Description**: Keeps the user data directory during uninstallation of the not portable version
- **Effect**: Does not remove the `%APPDATA%\Grayjay`
- **Use Case**: Useful if you want to preserve your settings and data for future installations. 

## Usage Examples

### Standard Installation (Default)
```bash
choco install grayjay
```
- Creates desktop shortcut
- Runs in portable mode (user data stored in installation directory)

### Non-Portable Installation
```bash
choco install grayjay --params="/NoPortable"
```
- Creates desktop shortcut
- User data stored in `%APPDATA%\Grayjay`

### No Desktop Shortcut
```bash
choco install grayjay --params="/NoShortcut"
```
- No desktop shortcut created
- Runs in portable mode

### Non-Portable + No Shortcut
```bash
choco install grayjay --params="/NoPortable /NoShortcut"
```
- No desktop shortcut created
- User data stored in `%APPDATA%\Grayjay`

### Keep App data
```bash
choco uninstall grayjay --params="/KeepAppData" 
```
- Keeps the `%APPDATA%\Grayjay` folder

## Notes

- The `/NoPortable` parameter addresses permission issues that can occur when Grayjay runs in portable mode from the Chocolatey installation directory
- When using `/NoPortable`, the application will have better integration with Windows user data management
- The `/KeepAppData` will only work when The `/NoPortable` parameter has been used during installation
- Package parameters are case-sensitive
