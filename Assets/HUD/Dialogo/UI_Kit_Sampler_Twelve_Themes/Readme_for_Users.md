# UI Kit Sampler - Free Game UI From Twelve Themes

**A free pixel-art UI sampler from twelve CSAF UI kits**, with files for **Godot 4** (a theme per kit and one project that
shows all twelve), **RPG Maker MZ** (a windowskin per kit), **Unity** (sprites with 9-slice borders in their .meta files,
UI Toolkit .uss), **Unreal Engine** (Draw As Box margins) and **GameMaker** (nine-slice values). For each of the twelve
themes you get a window panel, a dialogue box with a name plate, one button in four states (normal, hover, pressed,
disabled), an HP bar with its frame, a pointer and a selection cursor, the dialogue advance arrow (two frames) and hearts,
plus that theme's own extras: **168 widgets and 246 widget-state images in all**. Free to use in commercial and
non-commercial games (LICENSE.txt: no credit required, no resale as an asset pack). Each theme is a slice of a paid kit
with 58 to 88 widgets in pixel AND HD and a Ren'Py `gui/` set; the list of kits is below.

## The twelve themes

| Theme | Folder | The look | Free here | The paid kit |
| --- | --- | --- | --- | --- |
| **Bone and Brass** | `themes/bone-and-brass/` | Dark fantasy: heavy bone frames over iron-dark panels, brass corner caps, blood-red danger. | 11 widgets, 15 images | [Bone and Brass: Dark Fantasy UI Kit (Pixel + HD)](https://csaf.itch.io/bone-and-brass-dark-fantasy-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Casual Pop** | `themes/casual-pop/` | Bright flat candy for casual and party games: thick ink outline, a gloss strip, a chunky lip. | 14 widgets, 21 images | [Casual Pop: Chunky Bright Game UI Kit (Pixel + HD)](https://csaf.itch.io/casual-pop-chunky-bright-game-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Clean Slate** | `themes/clean-slate/` | Modern minimal: hairline outlines, rounded corners, a soft shadow, one cool blue accent. | 11 widgets, 15 images | [Clean Slate: Modern Minimal UI Kit (Pixel + HD)](https://csaf.itch.io/clean-slate-modern-minimal-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Codex Pages** | `themes/codex-pages/` | Book and journal: oxblood leather bands, parchment pages, gilt book-corner guards. | 23 widgets, 36 images | [Codex Pages: Book and Journal UI Kit (Pixel + HD)](https://csaf.itch.io/codex-pages-book-and-journal-ui-kit): 83 widgets, 183 images per mode, pixel + HD |
| **Ember Court** | `themes/ember-court/` | Classic pixel RPG: gilt frames over dark plum panels, a teal accent, crimson danger. | 11 widgets, 15 images | [Ember Court: Pixel RPG Dialogue and Menu UI Kit](https://csaf.itch.io/ember-court-pixel-rpg-dialogue-and-menu-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Felt Table** | `themes/felt-table/` | Card table: lacquered mahogany rails around green baize, a brass suit pip in each corner. | 18 widgets, 28 images | [Felt Table: Card Game and Deckbuilder UI Kit (Pixel + HD)](https://csaf.itch.io/felt-table-card-game-and-deckbuilder-ui-kit): 88 widgets, 173 images per mode, pixel + HD |
| **Four Shade** | `themes/four-shade/` | Exactly four colours: a handheld screen bezel corner, frames built on 8x8 tiles. | 12 widgets, 16 images | [Four Shade: Four-Colour Handheld UI Kit (Pixel + HD)](https://csaf.itch.io/four-shade-four-colour-handheld-ui-kit): 59 widgets, 126 images per mode, pixel + HD |
| **Hearthwood** | `themes/hearthwood/` | Cozy farming: honey wood with a carved channel and round log-end corners over cream paper. | 11 widgets, 15 images | [Hearthwood: Cozy Farming UI Kit (Pixel + HD)](https://csaf.itch.io/hearthwood-cozy-farming-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Iron Bastion** | `themes/iron-bastion/` | Medieval strategy: grey ashlar castle walls with corner turrets over dark oak panels. | 14 widgets, 21 images | [Iron Bastion: Medieval Strategy UI Kit (Pixel + HD)](https://csaf.itch.io/iron-bastion-medieval-strategy-ui-kit): 58 widgets, 125 images per mode, pixel + HD |
| **Night Terminal** | `themes/night-terminal/` | Sci-fi HUD: chamfered cyan steel, amber corner ticks, deep navy panels, segmented gauges. | 14 widgets, 18 images | [Night Terminal: Sci-Fi HUD UI Kit (Pixel + HD)](https://csaf.itch.io/night-terminal-sci-fi-hud-kit): 64 widgets, 131 images per mode, pixel + HD |
| **Silverpoint** | `themes/silverpoint/` | Minimal fantasy: warm vellum, sepia hairlines, an inner keyline with a bookplate notch. | 15 widgets, 25 images | [Silverpoint: Minimal Fantasy UI Kit (Pixel + HD)](https://csaf.itch.io/silverpoint-minimal-fantasy-ui-kit): 65 widgets, 153 images per mode, pixel + HD |
| **Verdant Frame** | `themes/verdant-frame/` | Drawn in the Verdant tilesets' palette: slate stone frames with ivy and daisy tufts. | 14 widgets, 21 images | [Verdant Frame: UI Kit for the Verdant Tilesets (Pixel + HD)](https://csaf.itch.io/verdant-frame-ui-kit-for-the-verdant-tilesets): 58 widgets, 125 images per mode, pixel + HD |

Every theme folder is that kit's own free sampler, byte for byte the file offered on the kit's page, with its own
Readme (full import notes for each engine) and LICENSE.

## What is in the folder

| Path | What |
| --- | --- |
| `godot/` | one Godot 4 project with all twelve themes: `uikit/<theme>/pixel/theme_pixel.tres`, each kit's pixel typeface in `uikit/<theme>/font/`, and a board scene (`demo/board.tscn`) that draws every theme side by side |
| `themes/<theme>/theme.json` | the one specification that theme's files were generated from |
| `themes/<theme>/pixel/` | `atlas.png` + `atlas.json` (every widget, state, region, 9-slice margin and text colour) and `sprites/`, one PNG per widget-state with a Unity `.meta` beside it |
| `themes/<theme>/godot/` | that theme's own runnable Godot 4 sampler project |
| `themes/<theme>/unity/` | UI Toolkit stylesheet (`uikit_pixel.uss`) with 9-slice values |
| `themes/<theme>/unreal/` | `brush_margins.csv`: Draw As Box margins in pixels and as 0..1 fractions |
| `themes/<theme>/gamemaker/` | `nineslice.json`: nine-slice values for every sprite |
| `themes/<theme>/rpgmaker_mz/` | `img/system/Window.png`: a standard 192x192 MZ windowskin |

Everything here is **pixel mode** (hard pixels, no blur); the HD versions are in the paid kits. Every frame, panel and
button is a 9-slice: stretch it to any size and the corners stay crisp; bars and their fills stretch along their length.
The gate rendered every 9-slice in all twelve themes stretched and tiled at five sizes (790 renders,
0 pixels of edge drift) and compared 878 of them with the widget drawn natively at that size: all equal.
Every text colour was measured against the fill it sits on (111 pairs): at least 4.55:1 contrast.

## Use one theme in Godot 4

1. Open `godot/project.godot` and run it to see all twelve themes on one screen.
2. Copy the folder of the theme you want, `godot/uikit/<theme>/`, into your project at the same path (the theme points at
   `res://uikit/<theme>/pixel/atlas.png` and its font).
3. Select your root Control and set **Theme** to `uikit/<theme>/pixel/theme_pixel.tres`. Buttons, panels, progress bars
   and labels under it pick the theme up.
4. Set Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter to **Nearest**, or the pixel art
   will blur, and use an integer stretch.
5. Theme type variations in every sampler theme: `PrimaryButton` (Button), `HpBar` (ProgressBar), `DialogueBox`,
   `NamePlate` (PanelContainer), `NamePlateLabel`, `DialogueLabel` (Label). Icons are of the type `UiKit`:
   `get_theme_icon("cursor_pointer", "UiKit")`. **ProgressBar: untick Show Percentage** (Godot's label is taller
   than the bar).

For RPG Maker MZ, Unity, Unreal and GameMaker, follow the engine notes in `themes/<theme>/Readme_for_Users.md`.

## What was run, and in which engine

- **Godot 4.7.2**: the board project in `godot/` was imported and run (Windows, Compatibility renderer); all 12 theme cells drew inside their frames, every themed control resolved to its kit's textures (103/103 themed controls), 0 error lines, and the screenshot was checked. Each theme's own sampler project (`themes/<theme>/godot/`) was also imported and run the same way: 12 of 12, every themed control resolved, 102/102 across the twelve.
- **RPG Maker MZ**: each of the 12 `themes/<theme>/rpgmaker_mz/img/system/Window.png` files was copied over `img/system/Window.png` of a blank MZ project and run in the MZ runtime: MZ loaded the file pixel for pixel, read its 32 text colours from it, and opened a message window with a name box on it with the frame corners drawn exactly as shipped (84 checks passed, and the same run without installing the file went red).

For Unity, Unreal Engine and GameMaker the files are provided and checked for consistency with each theme's
`atlas.json` (same regions, same 9-slice margins); treat the steps in each theme's Readme as the documented way to import
them.

## The paid kits

Each paid kit is the same theme with the full widget set (58 to 88 widgets: checkboxes, radios, toggles, sliders, tabs,
text fields, dropdowns, scrollbars, inventory slots, tooltips, MP / XP / stamina / boss bars, more frames and cursors,
and each theme's specials), in pixel mode AND HD mode (3x, anti-aliased), with a Ren'Py `gui/` set, a Godot demo and the
same files for every engine above. Links are in the table at the top. **Follow CSAF on itch.io** (https://csaf.itch.io)
to hear when a new kit ships.

## AI disclosure

Every widget, frame, icon, cursor and letter in this sampler was drawn by program code written by an AI, from one theme
specification per kit. The store page discloses this.

Copyright (c) 2026 Core Systems Asset Factory.
