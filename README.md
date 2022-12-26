# Gmod-NVGBase
Modular base for developers to create Night Vision Goggles for Gmod. Features a loadout system, player model whitelisting, overlay animations and transitions, post-processing, opaque overrides and more. The base also comes with an API with convenience function in order to easily integrate with gamemodes and other addons.

### Table of contents
1. Controls
2. Loadouts
3. Whitelist
4. API

## Controls
Controls are defined with clientside ConVars. Users can define their own in the console with the following commands:
| Command | Values | Description |
|---|---|---|
| NVGBASE_INPUT | 1 to 159 | Key used to toggle goggle. Refer to this page for the values: https://wiki.facepunch.com/gmod/Enums/KEY |
| NVGBASE_CYCLE | 1 to 159 | Key used to switch goggle. Refer to this page for the values: https://wiki.facepunch.com/gmod/Enums/KEY |

## Loadouts

## Whitelist
The whitelist can be turned on or off globally by an administrator of the server. To do so, use the following command:
```
NVGBASE_WHITELIST 0|1
```
When the whitelist if turned off, any goggle from the player's loadout can be used by his player model.

## API
An API ships with this addon to aid developers in interacting with the NVG Base. Here is a list of all available features.

> **_G:NVGBASE_IsWhitelistOn()**
> *Determine if player whitelisting is active on the server.*
>> Returns true if active, false otherwise.