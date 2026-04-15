# SCP: Continued Procedures

[Available on GameJolt](https://gamejolt.com/games/scpcontpr/998566)

## Requirements to build

The project uses Godot 4.5.2 as a base.
Godot 4.4 is not supported anymore since 6.0 - Cleanlight update.

### Building regular version

1. Project->Export
2. Choose your platform (e.g. Windows/Linux/Android)
3. Navigate to Resource tab and type in "Filter to exclude files/folders": `*.glb, *.gltf, Assets/*.bin, */Lite/*`

### Building lite version (for Web)
**In Lite version, some components are missing:**
There are no SCP-178 (may be reinstated in later update), *SCP: Unity* SCP-173 model, SCP-266 (spawnable), SCP-347 (spawnable), SCP-791, SCP-938 (spawnable), SCP-914.
1. Project->Export
2. Choose your platform (e.g. Web)
3. Navigate to Resource tab and type in "Filter to exclude files/folders": `*.glb, *.gltf, Assets/*.bin, */Optional/*`
4. Navigate to Features tab and type in "Custom (comma separated)": `Lite`

## About

Do your daily job at Site-[REDACTED].

Click/Tap - move/pick items (if you tap on character, they will go with you).

If Chaos Insurgency will raid your Site, call MTF using the button (in other times, the button won't work)

### Included SCPs

| SCP# | Full | Lite/Web version | Functionality |
|------|------|------------------|---------------|
|SCP-005|⁉️, since 6.0.0|⁉️, since 6.0.0|❓ Only used for specific usage, since there is no locked doors|
|SCP-018|✅, since 7.0.0|✅, since 7.0.0|✅ Full|
|SCP-023|✅, since 3.0.0|✅, since 5.7.0|✅ Full|
|SCP-067|✅, since 5.2.0|✅, since 5.7.0|✅ Full|
|SCP-162|✅, since 1.0.0|✅, since 5.8.0|✅ Full|
|SCP-173|✅, since 1.0.0|❓, since 5.7.0|✅ Full|
|SCP-178|✅, since 5.2.0|❌, 3d help wanted|✅ Full|
|SCP-249|✅, since 6.0.0|✅, since 6.0.0|✅ Full|
|SCP-266|✅, since 1.0.0|❌, 5.7.x only, removed in 5.8.0|✅ Full|
|SCP-347|✅, since 1.0.0|❌, 5.7.x-5.8.x only, removed in 6.0.0|❓ Partial|
|SCP-446|✅, since 5.3.0|✅, since 5.7.0|❌ None|
|SCP-458|✅, since 5.1.0|✅, since 5.7.0|✅ Full|
|SCP-522|✅, since 5.8.0|✅, since 5.8.0|✅ Full|
|SCP-649|⛄, since 5.5.0|⛄, since 5.7.0|✅ Full|
|SCP-650|✅, since 1.0.0|✅, since 5.7.0|✅ Full \(only if breached\)|
|SCP-686|✅, since 5.1.0|✅, since 5.7.0|❓ Partial \(hidden NSFW parts\)|
|SCP-791|✅, since 6.0.0|❌|📃 Task only|
|SCP-812|✅, since 1.0.0|✅, since 5.7.0|✅ Full|
|SCP-914|✅, since 2.0.0|❌, 5.7.x only, removed in 5.8.0|❓ Process only items|
|SCP-938|✅, since 5.0.0|❌|✅ Full \(since 6.0.0\)|
|SCP-939|✅, since 5.5.0|✅, since 5.8.0|✅ Full|
|SCP-1223|✅, since 6.1.0|✅, since 6.1.0|✅ Full|

#### Availability
⁉️ - Hidden - not always spawn.
✅ - Available.
❓ - Partial availability.
❌ - Unavailable.
<!-- 🎃 - Spawns only at October -->
⛄ - Spawns only in December.
#### Functionality
✅ - SCP object is fully implemented
❓ - SCP object is partly implemented
📃 - SCP object is implemented only for a task
❌ - SCP object is not compatible with SCP article

## Why this name?
- It is a recursive acronym - **S**CP: **C**ontinued **P**rocedures

## Note to Google Android users:
Please, check [tutorial to install apps without Google verification (effective since Sep 2026)](https://android-developers.googleblog.com/2026/03/android-developer-verification.html), since I don't plan to give all data and pay a fee to Google.

We **do not** distribute dangerous things in this app!

## License:
The game is based on SCP Foundation community.

[SCP Foundation community content are licensed under CC-BY-SA 3.0](https://scp-wiki.wikidot.com/licensing-guide)

The game is made in 2025 by Yni Viar.

This project, as a whole is dual-licensed.

If you are using code for non-SCP usage, feel free to use under [MIT License](/LICENSE.MIT)

If you are using code for SCP Foundation usage or the project, which includes CC-BY-SA assets,
use them under [GNU GPL 3 License](/LICENSE.GPL), as it is required by SCP Foundation / CC-BY-SA content usage.

The parts of the project can be used under license, mentioned in header (as of code and shaders),
as for assets, check corresponding to assets `readme.*`, `license.*` or check the folder naming for CC license.

## Contributing

You can:
- Report a bug.
- Suggest a new SCP object (before you suggest, see [suggestion rules](./SUGGESTING-IDEAS.md))
- Suggest an own model for replacement of existing one. (e.g own SCP-023 model instead of bad quality 3-rd party one, or own SCP-178-1 model).
- Suggest an own audio (SFX, music) for addition/replacement into the game