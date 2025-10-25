
# AddonProfiles

A World of Warcraft Classic addon that allows you to save and manage profiles of your addon configurations. Perfect for players who use different addons for different activities (leveling, raiding, PvP, etc.).

> **Version 2.0.0** - Complete rewrite with UI support!

<img width="1177" height="802" alt="image" src="https://github.com/user-attachments/assets/b5a1f3ed-e02c-4c8e-995b-ec1f634d5493" />


## Features

- **Profile Management**: Create multiple profiles for different gameplay scenarios
- **UI Interface**: Full graphical interface for managing profiles and selecting addons
- **Dependency Tracking**: Automatically include addon dependencies (configurable per-profile)
- **Scope Options**: Create profiles that are account-wide or character-specific
- **Migration Support**: Automatically migrates from v1.x profile format
- **Slash Commands**: Full command-line interface for power users

## Requirements

- World of Warcraft Classic: 20th Anniversary Edition (1.15.7)
- Ace3 library (included)

## Installation

1. Visit the [GitHub releases page](https://github.com/jmervine/wow-AddonProfiles/releases)
2. Download the latest release
3. Extract the downloaded zip file
4. Copy the `AddonProfiles` folder to your WoW `Interface/AddOns/` directory
5. Restart WoW or reload UI

## Usage

### UI Interface

Open the profile manager with:
- `/ap` or `/addonprofiles` or `/addons`
- Game Menu > Interface > AddOns > AddonProfiles

The UI has three main sections:

**Left Panel - Profile List**
- View all profiles (filter by Character or Account scope)
- Create new profiles
- Delete existing profiles
- Active profiles are marked with a checkmark

**Middle Panel - Addon Selection**
- Check/uncheck addons to include in the selected profile
- Search for specific addons
- Filter to show only compatible addons
- Select All / Deselect All buttons for quick management

**Right Panel - Profile Settings**
- Rename profiles
- Toggle automatic dependency inclusion
- View addon and dependency counts
- Apply profile (activates and reloads UI)
- Capture current addon state

### Slash Commands

```
/ap or /addonprofiles or /addons

Commands:
  /ap                           - Open UI (default)
  /ap show [profile]            - Show all profiles or specific profile details
  /ap load <profile>            - Activate a profile (reloads UI)
  /ap save <profile>            - Save current addon state to profile
  /ap new <profile> [account|char] - Create new profile
  /ap delete <profile>          - Delete a profile
  /ap help                      - Show help message
```

### Examples

```lua
-- Create a new character-specific raiding profile
/ap new Raiding char

-- Create an account-wide leveling profile
/ap new Leveling account

-- Show all profiles
/ap show

-- Show details for a specific profile
/ap show Raiding

-- Save current addon configuration to a profile
/ap save Raiding

-- Load and activate a profile
/ap load Raiding

-- Delete a profile
/ap delete OldProfile
```

## Profiles

### Profile Scopes

**Character-specific**: Profiles that are unique to each character. Perfect for character-specific needs.

**Account-wide**: Profiles that are shared across all characters on your account. Great for common setups.

### Profile Settings

**Auto-include dependencies**: When enabled, activating a profile will automatically enable all required dependencies for the selected addons. This is enabled by default for new profiles.

**Addon selection**: Manually select which addons to include in a profile. The UI shows dependency information for each addon.

## Migration from v1.x

If you're upgrading from AddonProfiles v1.x, your existing profiles will be automatically migrated to the new format on first load. All profiles will be converted to character-specific profiles, and the array-based format will be converted to the new map-based format.

The migration is non-destructive - your old `AddonProfilesStore` data is preserved alongside the new `AddonProfilesDB` data.

## Development

### Running Tests

```bash
# With Lua installed
make test

# With Docker installed
make ci
```

### Project Structure

```
AddonProfiles/
├── Core.lua              # Main addon initialization
├── AddonManager.lua      # Addon discovery and dependency management
├── ProfileManager.lua    # Profile CRUD operations
├── UI/                   # UI components
│   ├── MainFrame.lua     # Main window
│   ├── ProfileList.lua   # Profile management panel
│   ├── AddonList.lua     # Addon selection panel
│   └── ProfileSettings.lua # Profile settings panel
├── Libs/                 # Ace3 libraries
└── test/                 # Test suite
```

### Adding Features

When adding new functionality:

1. Add the feature to the appropriate module (AddonManager, ProfileManager, or UI)
2. Update tests in the corresponding test file
3. Run `make test` to ensure all tests pass
4. Update this README if adding user-facing features

## Troubleshooting

**Profile doesn't load correctly**: Make sure all addons in the profile are installed. Missing addons will be skipped.

**UI doesn't open**: Check for Lua errors with `/console scriptErrors 1`

**AddOns not enabling**: Some AddOns can't be enabled/disabled while in game. The profile will be applied on next UI reload.

**Dependencies not working**: Make sure "Auto-include dependencies" is enabled for the profile. Some addons may have optional dependencies that aren't automatically tracked.

## Known Issues

- Profile activation requires a UI reload (this is a WoW limitation)
- Optional addon dependencies are not automatically tracked
- Some Blizzard addons cannot be disabled

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass (`make test`)
5. Submit a pull request

## License

This addon is provided as-is for World of Warcraft players. Feel free to modify and share.

## Credits

- Original concept and v1.x implementation: Hound @ Atiesh (WotLK)
- v2.0 rewrite: Complete rewrite with UI support
- Ace3 libraries: Ace3 development team
- Testing framework: LuaUnit

## Changelog

### v2.0.0-alpha1 (Current)
- Complete rewrite with graphical UI
- Added profile scopes (account-wide vs character-specific)
- Added dependency auto-inclusion with per-profile toggle
- Added profile search and filtering
- Migration support from v1.x format
- Updated for WoW Classic 1.15.7 (20th Anniversary Edition)

### v0.0.3-beta1 (Legacy)
- Original slash command-based implementation
- Basic profile save/load functionality
- WotLK interface version
