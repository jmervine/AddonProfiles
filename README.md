# AddonProfiles

Simple World of Warcraft Addon designed to allow the user to save profiles of
their current Addon enabled state to quickly switch from one to another. The
idea being, if they use a lot of Addons, as I do, they'll want some enabled while
leveling, others enabled while in the open world and still others while raiding.

> ### Warning
>
> This is my first Addon, is still developement, and was developed with WotLK in
> mind and the focused test environment.

## Install

> NOTE: While in beta, this only supports install directly from Github.

1. Visit the [Github releases page](https://github.com/jmervine/wow-AddonProfiles/releases).
1. Download the latest release.
1. Extract the downloaded `wow-AddonProfiles-{{version}}.zip` file and extract it.
1. Rename the extracted directory to `AddonProfiles`.
1. Copy `AddonProfiles` to you WoW Addons directory.

## Usage
```
[AddonProfiles] Usage: /addonprofiles [option] (aliases: 'at', 'addons')
[AddonProfiles]   'show [PROFILE]': Show saved profile or profiles.
[AddonProfiles]   'addons ': List currently enabled Addons.
[AddonProfiles]   'help [SUBCOMMAND]': Show help message.
[AddonProfiles]   'load PROFILE': Load saved 'PROFILE'.
[AddonProfiles]   'save PROFILE': Saved current Addon state as 'PROFILE'.
[AddonProfiles]   'delete PROFILE': Delete saved 'PROFILE'.
```

## Development

#### WoW Builtins

All WoW builtins that are used in the current iteration of this Addon
are included via `Libs/LUAUnit/WowStubs/WowStubs.lua`. If you are adding and
testing new functionality that requires a WoW builtin, add it there and be sure
to add a test for it in `test/stub_test.lua`.

#### Running Tests Locally

There a few options:
#### _With WSL or MacOs AND Lua Installed_
```
make test
```

#### _With WSL or MacOs AND Docker Installed_
```
make ci
```

#### _Without WSL or MacOs AND Lua Installed_
```
test ./test/test.lua -v
```
