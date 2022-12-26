# Gmod-NVGBase
Modular base for developers to create Night Vision Goggles for Gmod. Features a loadout system, player model whitelisting, overlay animations and transitions, post-processing, opaque overrides and more. The base also comes with an API with convenience function in order to easily integrate with gamemodes and other addons.

### Table of contents
1. Controls
2. Loadouts
3. Whitelist
4. API

## Controls
Controls are defined with clientside ConVars. Users can define their own in the console with the following commands:
| Command | Default | Values | Description |
|---|---|---|---|
| NVGBASE_INPUT | 24 (KEY_N) | 1 to 159 | Key used to toggle goggle. Refer to this page for the values: https://wiki.facepunch.com/gmod/Enums/KEY |
| NVGBASE_CYCLE | 23 (KEY_M) | 1 to 159 | Key used to switch goggle. Refer to this page for the values: https://wiki.facepunch.com/gmod/Enums/KEY |

## Loadouts

## Whitelist
The whitelist can be turned on or off globally by an administrator of the server. To do so, use the following command:
```
NVGBASE_WHITELIST 0|1
```
When the whitelist if turned off, any goggle from the player's loadout can be used by his player model.

## API
An API ships with this addon to aid developers in interacting with the NVG Base. Here is a list of all available endpoints.

### ![shared](images/shared.png?raw=true "shared") **_G:NVGBASE_IsWhitelistOn()**
>
> *Determine if player whitelisting is active on the server.*
>
>> Returns true if active, false otherwise.

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_IsBoundingBoxVisible(target, maxDistance)**
>
> *Determine if an entity is visible by the player.*
>
>> Parameters:
>> | Name | Type | Description |
>> |---|---|---|
>> | target | entity | The entity to test. |
>> | maxDistance | int | Max test distance in hammer units. |
>
>> Returns true if visible, false otherwise.

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_AnimGoggle(gogglesActive, anim, bodygroup, on, off)**
>
> *Utility function to animate playermodel. Can also be used to change playermodel bodygroup.*
>
>> Parameters:
>> | Name | Type | Description |
>> |---|---|---|
>> | gogglesActive | bool | Whether the goggle is active or not. |
>> | anim | enum | **optional** The anim (ACT) gesture to use to animate the playermodel. Use nil if not animating. |
>> | bodygroup | int | **optional** The bodygroup ID to modify. Use nil if not changing bodygroup. |
>> | on | int | The bodygroup's "on" value for the goggles. |
>> | off | int | The bodygroup's "off" value for the goggles. |

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_GetGoggleToggleKey()**
>
> *Return the player's key used to toggle NVG goggle.*
>
>> Returns Goggle toggle key value.

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_GetGoggleSwitchKey()**
>
> *Return the player's key used to switch NVG goggle.*
>
>> Returns Goggle switch key value.

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_GetNextToggleTime()**
>
> *If you are comparing against this value, simply check that CurTime() is greater for "can toggle".*
>
>> Returns the next time the goggle and be toggled.

### ![shared](images/shared.png?raw=true "shared") **player:NVGBASE_GetNextSwitchTime()**
>
> *If you are comparing against this value, simply check that CurTime() is greater for "can switch".*
>
>> Returns the next time the goggle and be switched.