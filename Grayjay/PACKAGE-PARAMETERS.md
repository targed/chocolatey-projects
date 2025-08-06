# Grayjay Package Parameters

This document describes the available package parameters for customizing the Grayjay installation.

## Available Parameters

### `/Portable`
- **Description**: Enables portable mode by removing the portable marker file
- **Effect**: Grayjay will store user data in the installation directory
- **Use Case**: Recommended for modified installations where you want user data stored in the application directory

### `/NoShortcut`
- **Description**: Prevents creation of a desktop shortcut
- **Effect**: No desktop shortcut will be created during installation
- **Use Case**: Useful for automated deployments or when you don't want desktop clutter

### `/NoStartMenuShortcut`
- **Description**: Prevents creation of a start menu shortcut
- **Effect**: No start menu shortcut will be created during installation
- **Use Case**: Useful for automated deployments or when you don't want start menu clutter

### `/RemoveAppData`
- **Description**: Removes the user data directory during uninstallation of the not portable version. 
- **Effect**: Removes  the `%APPDATA%\Grayjay`
- **Use Case**: Useful if you want to preserve or remove your settings and data for future installations. 

## Usage Examples

### Standard Installation (Default)
```bash
choco install grayjay
```
- Creates desktop shortcut
- Runs in non-portable mode (user data stored in installation directory)

### Portable Installation
```bash
choco install grayjay --params="/Portable"
```
- Creates desktop shortcut
- User data stored in `%APPDATA%\Grayjay`

### No Desktop Shortcut
```bash
choco install grayjay --params="/NoShortcut"
```
- No desktop shortcut created
- Runs in portable mode

### Portable + No Shortcut
```bash
choco install grayjay --params="/Portable /NoShortcut"
```
- No desktop shortcut created
- User data stored in (user data stored in installation directory)

### Remove App data
```bash
choco uninstall grayjay --params="/RemoveAppData" 
```
- Removes the `%APPDATA%\Grayjay` folder

## Notes

- The `/Portable` parameter addresses permission issues that can occur when Grayjay runs in portable mode from the Chocolatey installation directory
- When using `/Portable`, the application will have better integration with Windows user data management
- The `/RemoveAppData` will only work when The `/Portable` parameter has been used during installation. Otherwise, regular instillation will automatically remove the app data contained within. 
- Package parameters are case-sensitive
