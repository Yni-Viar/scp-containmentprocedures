extends Resource
class_name SettingsResource
## Made by Yni, licensed under MIT License.

## KeyBoard, MouseButton, JoyPad
enum InputMethod {KB, MB, JP}

enum Lighting {NONE, LIGHTMAP, REALTIME}

enum Renderer {OPENGL, RD_MOBILE, RD_FORWARD_PLUS}

## Music
@export var music: float = 1.0
## Sound
@export var sound: float = 1.0
## Mouse sensitivity
@export var mouse_sensitivity: float = 0.05
## Glow setting
@export var glow: bool = true
## Reflection probe setting
@export var reflection_probe: bool = true
## Current enemy spawn value
@export var ci_spawn: int = 0
## Hard mode
@export var time_limited: bool = false
## Zen mode
@export var zen_mode: bool = false
## Music volume
@export var music_volume: float = 1.0
## Keybinds
@export var keybinds: Dictionary[String, Array] = {
	"look": [InputMethod.MB, MOUSE_BUTTON_RIGHT],
	"click": [InputMethod.MB, MOUSE_BUTTON_LEFT],
	"camera_rotate_left": [InputMethod.KB, KEY_A],
	"camera_rotate_right": [InputMethod.KB, KEY_D],
	"toggle_mode": [InputMethod.KB, KEY_SPACE],
	"inventory": [InputMethod.KB, KEY_TAB],
	"photomode": [InputMethod.KB, KEY_P],
	"debug_console": [InputMethod.KB, KEY_QUOTELEFT]
}
## SSAO
@export var ssao: bool = false
## Tonemapper
@export var tonemapper: Environment.ToneMapper = Environment.TONE_MAPPER_LINEAR
## AI enabled
@export var ai_enabled: bool = false
## Lighting
@export var lighting: Lighting = Lighting.LIGHTMAP
## Rendering
@export var renderer: Renderer = Renderer.OPENGL
