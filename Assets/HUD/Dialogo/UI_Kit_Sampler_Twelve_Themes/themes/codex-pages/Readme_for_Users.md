# Codex Pages - Book and Journal UI Kit - FREE SAMPLER

This is the free sampler of the Codex Pages UI Kit: 23 widgets (36 widget-state images) in pixel mode, with a Godot 4 theme and demo, the RPG Maker MZ windowskin and the margin tables for the other engines. The full kit has the complete widget set in pixel AND HD.

One theme, rendered from one specification into every format below.

- **23 distinct widgets, 36 widget-state images** per mode (a widget is one element, for example a button;
  a widget-state image is that element in one state, for example the button when hovered).
- **Pixel mode (hard pixels, 1x, every pixel a palette colour).**
- **15 of the widgets are 9-slice** (pages, panels, frames, buttons, bars, fields, tabs, bookmarks): stretch them to
  any size and the corners stay crisp. Every 9-slice was rendered stretched and tiled at five sizes and compared with the
  widget drawn natively at that size: 0 pixels of edge drift.
- Every text colour was measured against the fill it sits on: at least 4.5:1 contrast.
- Interactive widgets ship every state: buttons normal / hover / pressed / disabled, tabs, bookmarks and index tabs
  normal / hover / active / disabled, text field normal / hover / focused / disabled, quest entries and inventory slots
  normal / hover / selected / disabled.
- A pixel typeface drawn by the same generator (printable ASCII), used by the Godot themes and the demo.
- **The look:** oxblood leather bands around parchment pages, ink-blue bookcloth for the main buttons, wax-seal crimson for
  danger, dark brown ink on the paper.
- **Gilt corner guards:** the heavy frames (window, dialogue box, portrait frame and the MZ windowskin) carry a gilt
  book-corner guard over each corner, and each page over its two outer corners, the way metal corners protect an old
  ledger: a triangle with an engraved line and, on the big frames, a stud. They sit inside the 9-slice corners, so they
  stay whole at any size.

## The book

- **Pages:** `page_left` and `page_right`, one page each of an open book, base 64x80 (pixel). Both are
  9-slice: the leather cover rim and the stacked page edges sit in the OUTER margins and the gutter shadow in the INNER
  margin, so a left page and a right page placed side by side with no gap make a spread at any size, and the fold stays a
  fold. Margins (pixel) of `page_left`: left 9, top 9, right 5, bottom 10; `page_right` is its mirror: left 5, top 9, right 9, bottom 10.
  The page text is yours; the Godot theme gives it the measured ink.
- **Ribbon bookmarks:** `bookmark_red`, each normal / hover / active / disabled. Vertical 9-slice
  (stretch them taller; the swallowtail stays whole). Active carries a gilt thread: the bookmark of the open page.
- **Index tabs:** `edge_tab_blue`, each normal / hover / active / disabled: paper tabs that stick out of a page's edge, their
  flat left end meant to sit under the page. Horizontal 9-slice, with a measured text colour.
- **Quest log:** `quest_entry` in normal / hover / selected / disabled (an open quest, hover, the TRACKED quest with a
  diamond marker and a blue rule, a DONE quest ticked and greyed). Horizontal 9-slice, the marker in the left margin.
- Page pieces: `chapter_heading`, `page_number`, `drop_cap`. `chapter_heading`: a paper plate between gilt
  rules with a fleuron at each end; `flourish_divider`: a gilt rule between two lozenges; `page_number`: a gilt cartouche;
  `drop_cap`: an illuminated initial frame (a crimson ground in a gilt frame) for the first letter of a page.
- Icons and cursors: `stamp_active`, `stamp_done`, `wax_seal`, `cursor_quill`. The four stamps (new, active, done,
  failed) are quest-state marks in four inks.
- In Godot: `PageLeft`, `PageRight`, `ChapterHeading`, `PageNumber`, `DropCap`, `FlourishDivider` are PanelContainers;
  `PageLabel`, `ChapterLabel`, `PageNumberLabel`, `DropCapLabel` are Labels in the measured inks; `QuestEntry`,
  `BookmarkRed`, `BookmarkBlue`, `BookmarkGreen`, `BookmarkGold`, `EdgeTabRed`, `EdgeTabBlue`, `EdgeTabGreen` are
  Buttons (set `toggle_mode = true`: SELECTED / ACTIVE is the pressed style); every icon and every animation frame is a
  theme icon, for example `theme.get_icon("wax_seal", "UiKit")` or `theme.get_icon("page_turn_frame3", "UiKit")`. The
  demo's first panel is an open journal built from them. (The free sampler carries one of each kind.)

## What is in the folder

| Folder | What |
| --- | --- |
| `theme.json` | the one specification every file was generated from (colours, frame bands, corner radius, book paper tones) |
| `pixel/` | `atlas.png` + `atlas.json` (every widget, state, region, 9-slice margin and text colour), `sprites/` one PNG per widget-state with a Unity `.meta` beside it |
| `godot/` | a runnable Godot 4 project: themes (`uikit/codex-pages/pixel/theme_pixel.tres`), the typeface, and a demo scene |
| `unity/` | UI Toolkit stylesheets (`.uss`) with 9-slice values |
| `unreal/` | `brush_margins.csv`: Draw As Box margins in pixels and as 0..1 fractions |
| `gamemaker/` | `nineslice.json`: nine-slice values for every sprite |
| `rpgmaker_mz/` | `img/system/Window.png`: a standard 192x192 MZ windowskin |
| (Ren'Py) | the Ren'Py `gui/` set is HD and ships in the full kit |

## What was run, and in which engine

The files for every engine are generated from the same atlas and checked against it. They were RUN in these engines:

- **Godot 4.7.2**: the demo project in godot/ was imported and run (Windows, Compatibility renderer); every themed control resolved to the kit's textures, including an open journal of two Page panels, the chapter heading, four quest-entry Buttons, the drop cap, the page numbers, three index-tab Buttons and three bookmark Buttons, and the screenshot was checked. The pixel and HD themes were also assigned in a blank project to a Button, a ProgressBar (HpBar), a PanelContainer (DialogueBox), both Page panels and the quest-entry, bookmark and index-tab Buttons, whose hover, pressed (selected or active) and disabled styles each resolved to its own region of the atlas with the shipped margins.
- **Unity 6000.5.7f1**: pixel/sprites and hd/sprites were copied with their .meta files, and both .uss files beside them, into a blank Unity 6 project; Unity read back every sprite with the shipped GUID, its 9-slice border (Sprite.border) equal to atlas.json, Sprite (2D and UI) / Single, Point filter for pixel and Bilinear for HD, no mipmaps, 16 / 100 pixels per unit and the native size; both stylesheets loaded; sliced uGUI Images of the panels were rendered stretched with the gilt guards whole and the screenshot was checked; the Editor log had no kit error or warning and no compile error.
- **RPG Maker MZ**: rpgmaker_mz/img/system/Window.png was copied over img/system/Window.png of a blank MZ project and run in the MZ runtime; MZ loaded the file pixel for pixel, all 32 text colours came from its swatches, and a message window with a name box opened and paused on it with its frame corners drawn exactly as shipped; 0 page errors; the screenshot was checked.

For the other engines the files are provided and checked for consistency with `atlas.json` (same regions, same 9-slice
margins); they have not been opened in that engine by us, so treat the steps below as the documented way to import them.

## Engine notes

## Godot 4 (Codex Pages - Book and Journal UI Kit)

The `godot/` folder is a complete Godot 4 project. Open `godot/project.godot` to see every widget running before you copy
anything: the demo builds the same screen twice, once with the pixel theme and once with the HD theme.

1. Copy `godot/uikit/codex-pages/` into your project (keep the folder; the themes point at
   `res://uikit/codex-pages/<mode>/atlas.png`). If you move it, open each `.tres` in a text editor and change that path.
2. Assign a theme: select your root Control, set **Theme** to `uikit/codex-pages/pixel/theme_pixel.tres` (pixel art games)
   or `uikit/codex-pages/hd/theme_hd.tres` (high-resolution games). Every child control inherits it.
3. **Pixel theme only:** set Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter to
   **Nearest**, or the pixel art will blur. Use an integer stretch (Project Settings > Display > Window > Stretch:
   mode `canvas_items` or `viewport`, scale mode `integer`).
4. Styled out of the box: Button, OptionButton, CheckBox, CheckButton (toggle), LineEdit, ProgressBar, HSlider,
   VScrollBar, TabContainer / TabBar, PanelContainer, Panel, PopupMenu, tooltips, Label colours.
5. Extra looks are **theme type variations**. Set a control's **Theme Type Variation** to one of:
   `PrimaryButton`, `DangerButton`, `SquareButton`, `KeyCap`, `CloseButton`, `ArrowLeftButton`, `ArrowRightButton`
   (Button) · `HpBar`, `MpBar`, `XpBar`, `StaminaBar`, `BossBar` (ProgressBar) · `DialogueBox`, `NamePlate`,
   `InsetPanel`, `HeaderPanel`, `TitleBar`, `CardPanel`, `DarkPanel`, `PopupFrame`, `PortraitFrame`, `MinimapFrame`,
   `ThinFrame`, `InventorySlot`, `TooltipFrame` (PanelContainer) · `NamePlateLabel`, `HeaderLabel`, `DialogueLabel`,
   `CardLabel`, `TooltipText` (Label).
6. Every panel is a 9-slice (`StyleBoxTexture` with texture margins), so it can be any size. Bars, tracks, the title bar
   and the dropdown stretch horizontally only: keep their height at the native height listed in `pixel/atlas.json`.
   **ProgressBar: untick Show Percentage.** Godot shows it by default, and the percentage label is taller than the
   kit's bars (8 px pixel, 24 px HD), so the bar grows and the fill overhangs its frame. Put a Label beside the bar
   instead, as the demo does (`HP 72/100`).
7. Cursors, hearts, the coin, the star, the notice badge and the dialogue advance arrow are **theme icons** of the type
   `UiKit`: `get_theme_icon("heart_full", "UiKit")` from any themed control, or `theme.get_icon("icon_coin", "UiKit")`.
   The advance arrow has two frames, `advance_arrow_frame0` and `advance_arrow_frame1`. The single files are also in
   `pixel/sprites/` and `hd/sprites/`.
8. **Typeface.** Both themes set the kit's own pixel typeface as the default font: a ready-made `FontFile` resource
   in `godot/uikit/codex-pages/font/` (`codex-pages_pixel.tres` at size 11, `codex-pages_hd.tres` at size 33, the
   same face at 3x). It needs no import step. Keep the theme's default font size (11 pixel, 33 HD): a bitmap face is
   drawn crisp at its own size. Covers printable ASCII (letters, digits, punctuation); to use your own font instead,
   set **Default Font** on the theme.

## Unity (Codex Pages - Book and Journal UI Kit)

1. Copy `pixel/sprites/` (pixel art projects) or `hd/sprites/` (high-resolution projects) into your `Assets/` folder,
   **with the `.meta` files next to the PNGs**. The metas import each file as a Sprite (2D and UI) with its 9-slice
   border already set (`spriteBorder`), Point filtering for pixel art, Bilinear for HD, and no mipmaps.
2. If your project already used those file names, Unity may assign new GUIDs; the borders are also listed in
   `unreal/brush_margins.csv` (pixel values, left/top/right/bottom) so you can type them into the Sprite Editor's
   Border fields.
3. **uGUI (Canvas):** put the sprite on an **Image** and set **Image Type: Sliced**. For buttons, set the Button's
   Transition to **Sprite Swap** and use the `__hover`, `__pressed` and `__disabled` files of the same widget.
4. **UI Toolkit:** copy `unity/uikit_pixel.uss` (or `uikit_hd.uss`) next to the sprite folder you copied, keeping the
   relative path `../pixel/sprites/` (or `../hd/sprites/`), add it to your UXML's style sheets and use the classes
   `uikit-button`, `uikit-button-primary`, `uikit-button-danger`, `uikit-panel-window`, `uikit-dialogue-box`,
   `uikit-nameplate`, `uikit-text-field` and others listed in the file. The `-unity-slice-*` values are the 9-slice.
5. Pixel art: set **Pixels Per Unit** to match your game (the metas use 16 for pixel, 100 for HD) and set the Canvas
   Scaler to an integer scale factor so pixels stay square.
6. Bars, tracks, the title bar and the dropdown are horizontal-only slices: keep their native height.

## Unreal Engine 5 (Codex Pages - Book and Journal UI Kit)

1. Drag the PNGs from `hd/sprites/` (or `pixel/sprites/`) into the Content Browser. For pixel art, open each texture
   (or select them all and use **Asset Actions > Bulk Edit via Property Matrix**) and set **Filter: Nearest**,
   **Texture Group: UI**, **Mip Gen Settings: NoMipmaps**, **Compression: UserInterface2D (RGBA)**.
2. In a UMG widget, set an Image's or Border's brush to the texture, **Draw As: Box**, and type the **Margin** values
   from `unreal/brush_margins.csv`: the columns `margin_left` .. `margin_bottom` are already the 0..1 fractions UMG
   expects (pixel values are in the `_px` columns).
3. Buttons: set the Button's Style Normal / Hovered / Pressed / Disabled brushes to the `__normal`, `__hover`,
   `__pressed` and `__disabled` textures of one widget, each Draw As Box with the same margins.
4. Progress bars: Background Image = `bar_frame`, Fill Image = `bar_hp_fill` (or mp, xp, stamina, boss), both Draw As
   Box with their margins; keep the native height.
5. Text colours that pass a 4.5:1 contrast check against each fill are in `hd/atlas.json` (`textColor` per state).

## GameMaker (Codex Pages - Book and Journal UI Kit)

1. Create a sprite per file you want (Resources > Create Sprite > Import) from `pixel/sprites/` or `hd/sprites/`.
   `gamemaker/nineslice.json` lists a suggested sprite name, the file, its size and its nine-slice values for every
   cell.
2. Nine-slice: open the sprite, click **Nine Slice**, tick **Enabled** and enter Left / Top / Right / Bottom from
   `nineslice.json`. Leave the guides on **Stretch** (the edges are built so Stretch and Repeat give the same pixels).
3. Draw at any size with `draw_sprite_stretched(spr_..., 0, x, y, w, h);` the corners stay crisp.
4. Pixel art: in Game Options, untick **Interpolate colours between pixels**, and keep the camera at an integer scale.
5. Button states: the `_normal`, `_hover`, `_pressed` and `_disabled` files of one widget can be frames 0-3 of a single
   sprite (import them in that order) so `image_index` picks the state.
6. Text colours that pass a 4.5:1 contrast check against each fill are in `pixel/atlas.json` (`textColor`).

## RPG Maker MZ (Codex Pages - Book and Journal UI Kit)

No plugin needed.

1. Copy `rpgmaker_mz/img/system/Window.png` into your project's `img/system/` folder, replacing the existing
   `Window.png` (keep a backup of the old one). It is a standard 192x192 MZ windowskin: window back, frame with scroll
   arrows, selection cursor, the four-frame "next page" sign and the 32 text colours.
2. Text colours follow MZ's numbering (`\C[n]` in messages): 0 normal text, 16 system, 17 crisis, 18 death,
   19 gauge back, 20-21 HP gauge, 22-23 MP gauge, 24 power up, 25 power down, 28-29 TP gauge.
3. For other UI (HP bars, hearts, portrait frames, buttons in custom scenes), the single files in `pixel/sprites/` are
   ready to load with `ImageManager.loadBitmap`, and `pixel/atlas.json` lists every 9-slice margin.
4. Window opacity and tone are still controlled by MZ's database (System 1 > Window Color) and the window's
   `backOpacity`.
5. MZ draws window text with a dark outline by default (`ColorManager.outlineColor()`, `rgba(0, 0, 0, 0.6)` in MZ's
   own `rmmz_managers.js`). On a light window back the letters therefore look heavier than on a dark one. If you want
   thinner letters on a light skin, use your message plugin's outline option or a small plugin of your own that
   overrides `ColorManager.outlineColor`. This kit ships no plugin.

## Ren'Py (Codex Pages - Book and Journal UI Kit)

Made for the default Ren'Py 8 GUI at 1920x1080.

1. Back up your project's `game/gui/` folder, then copy the contents of `renpy/game/gui/` over it. The file names are
   the ones the default GUI template already uses (`textbox.png`, `namebox.png`, `frame.png`, `button/`, `slider/`,
   `scrollbar/`, `bar/`), so no screen code changes are needed for them.
2. Open `renpy/gui_values.rpy.txt`. For each line, find the line with the same name in your `game/gui.rpy` and
   replace it (Ren'Py refuses a variable defined twice, so paste over, never add). These set the text colours and the
   9-slice `Borders(...)` for each framed image.
3. `textbox.png` is drawn at 1860x270 for a 1080p game; if your game is 1280x720, resize it to 1240x180 with nearest
   neighbour or use `hd/sprites/dialogue_box__normal.png` with `Frame(...)` and the borders from `hd/atlas.json`.
4. Delete the `.rpyc` files or use **Force Recompile** in the launcher after replacing `gui.rpy` values.
