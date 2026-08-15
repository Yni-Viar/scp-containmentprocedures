## How to quickly replace NPC model

### Requirements

- Your filename should be .GLB file
- Your filename should be in this format:
   - For SCP-131: `Scp`*number*`_`*A or B*`.glb`
   - For other SCPs: `Scp`*number*`.glb`
- Your model should face (or be rotated to) +Y (in Blender) coordinate

### Steps

1🪟. Windows-specific - Go to `%APPDATA%\\SCPContPr\\mods\\puppets\\builtin\\`

1🐧. Linux-specific - Go to `~/.local/share/SCPContPr/mods/puppets/builtin/`

2. Copy your renamed file into one of these folders (if they exist) - `scp`*number*
3. Your SCP will likely spawn in one of the rounds

### How to add custom processing to built-in NPC

### Requirements

- Your filename should be named as [Plugin API script naming (chapter `Script Naming/Common` or `Script Naming/Built-in classes`)](./PLUGIN_API.md).

### Steps

1🪟. Windows-specific - Go to `%APPDATA%\\SCPContPr\\mods\\puppets\\builtin\\`

1🐧. Linux-specific - Go to `~/.local/share/SCPContPr/mods/puppets/builtin/`

2. Move into your NPC folder
3. If `📁 scripts` folder was not created - you should create it.
4. Create and program a script with defined name.