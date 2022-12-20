# AddOnTemplates

Simple World of Warcraft AddOn designed to allow the user to save templates of
their current AddOn enablement state to quickly switch from one to another. The
idea being, if they use a lot of AddOns, as I do, they'll want some enabled while
leveling, others enabled while in the open world and still others while raiding.

> ### Warning
>
> This is my first AddOn, is still developement, and was developed with WotLK in
> mind and the focused test environment.

## Install

> NOTE: While in beta, this only supports install directly from Github.

1. Visit the [Github releases page](https://github.com/jmervine/wow-AddOnTemplates/releases).
1. Download the latest release.
1. Extract the downloaded `wow-AddOnTemplates-{{version}}.zip` file and extract it.
1. Rename the extracted directory to `AddOnTemplates`.
1. Copy `AddOnTemplates` to you WoW AddOns directory.

## Usage
```
[AddOnTemplates] Usage: /addontemplates [option] (aliases: 'at', 'addons')
[AddOnTemplates]   'show [TEMPLATE]': Show saved template or templates.
[AddOnTemplates]   'addons ': List currently enabled AddOns.
[AddOnTemplates]   'help [SUBCOMMAND]': Show help message.
[AddOnTemplates]   'load TEMPLATE': Load saved 'TEMPLATE'.
[AddOnTemplates]   'save TEMPLATE': Saved current AddOn state as 'TEMPLATE'.
[AddOnTemplates]   'delete TEMPLATE': Delete saved 'TEMPLATE'.
```

## Development

#### WoW Builtins

All WoW builtins that are used in the current iteration of this AddOn
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
