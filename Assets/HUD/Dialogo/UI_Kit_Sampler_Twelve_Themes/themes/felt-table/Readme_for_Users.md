# Felt Table - Card Game and Deckbuilder UI Kit - FREE SAMPLER

This is the free sampler of the Felt Table UI Kit: 18 widgets (28 widget-state images) in pixel mode, with a Godot 4 theme and demo, the RPG Maker MZ windowskin and the margin tables for the other engines. The full kit has the complete widget set in pixel AND HD.

One theme, rendered from one specification into every format below.

- **18 distinct widgets, 28 widget-state images** per mode (a widget is one element, for example a button;
  a widget-state image is that element in one state, for example the button when hovered).
- **Pixel mode (hard pixels, 1x, every pixel a palette colour).**
- **11 of the widgets are 9-slice** (panels, frames, buttons, bars, fields, tabs): stretch them to any size and the
  corners stay crisp. Every 9-slice was rendered stretched and tiled at five sizes and compared with the widget drawn
  natively at that size: 0 pixels of edge drift.
- Every text colour was measured against the fill it sits on: at least 4.5:1 contrast.
- Interactive widgets ship every state: buttons normal / hover / pressed / disabled, tabs normal / hover / active /
  disabled, text field normal / hover / focused / disabled, cards, card slots and inventory slots normal / hover /
  selected / disabled.
- A pixel typeface drawn by the same generator (printable ASCII), used by the Godot themes and the demo.
- **The look:** lacquered mahogany rails around green baize, brass buttons with dark ink, crimson lacquer for danger and
  for the card back, cream text on the felt.
- **Suit corners:** a brass stringing line is inlaid in every heavy rail (window, dialogue box, portrait frame, square
  button, card back and the MZ windowskin), and each heavy frame carries a brass playing-card suit at its corners: spade
  top left, heart top right, club bottom left, diamond bottom right. They sit inside the 9-slice corners, so they stay
  whole at any size.

## The card table

- **One card frame (the full kit has one per card type)** (`card_attack`), each in **normal / hover /
  selected / disabled** (selected = the card is picked up, disabled = it cannot be played). Base size 52x74
  (pixel) and 156x222 (HD). Every card frame is a 9-slice: the cost gem and the name plate live in the
  TOP margin and the rules box in the BOTTOM margin, so stretching a card widens all of it and only makes the art window
  taller. The name plate, rules box and cost gem keep their size, as they do on a real card. Margins (pixel):
  left 12, top 19, right 7, bottom 32; smallest size 20x52.
- The card TEXT and the card ART are yours: the frame is the frame. Text areas (pixel units from the card's top-left):
  cost digit on the gem at x 3, y 1 (the gem is 11x11); name on the name plate from x 12, rows 6 to 15; rules in the rules
  box from x 6, two lines of the kit typeface from row 45; art inside the art window from row 19, x 6.
- `card_back` (9-slice, brass stringing + suit corners) and `card_back_emblem` (a fixed-size mark to centre on it: a
  centred mark cannot live in a 9-slice centre). `card_slot`: a play-zone or hand recess in the felt; hover lights its
  outline (the drop target), selected lights it brighter.
- Table pieces: `card_plate`, `end_turn`. `end_turn` is a brass plaque button in four
  states; `turn_banner` a swallowtail ribbon; `price_tag` a shop tag with a punched hole; `badge_count` the count plate for
  a pile; `card_plate` the parchment name plate on its own, for keyword boxes and shop labels.
- Icons: `cost_gem`, `energy_full`, `intent_attack`.
- In Godot: a card is a `Button` with `theme_type_variation` `CardAttack` / `CardSkill` / `CardPower` / `CardCurse` (hover is
  its hover style, SELECTED is its pressed style: set `toggle_mode = true`); `CardSlot` is a Button too; `EndTurnButton`;
  `CardBack`, `CardPlate`, `TurnBanner`, `PriceTag`, `CountBadge` are PanelContainers; `CardPlateLabel`, `CostLabel`,
  `EnergyLabel`, `TurnBannerLabel`, `PriceTagLabel`, `CountBadgeLabel` are Labels in the measured inks; every icon is a
  theme icon, for example `theme.get_icon("intent_attack", "UiKit")`. The demo's first panel is a table built from them.

## What is in the folder

| Folder | What |
| --- | --- |
| `theme.json` | the one specification every file was generated from (colours, rails, corner radius, card colours) |
| `pixel/` | `atlas.png` + `atlas.json` (every widget, state, region, 9-slice margin and text colour), `sprites/` one PNG per widget-state with a Unity `.meta` beside it |
| `godot/` | a runnable Godot 4 project: themes (`uikit/felt-table/pixel/theme_pixel.tres`), the typeface, and a demo scene |
| `unity/` | UI Toolkit stylesheets (`.uss`) with 9-slice values |
| `unreal/` | `brush_margins.csv`: Draw As Box margins in pixels and as 0..1 fractions |
| `gamemaker/` | `nineslice.json`: nine-slice values for every sprite |
| `rpgmaker_mz/` | `img/system/Window.png`: a standard 192x192 MZ windowskin |
| (Ren'Py) | the Ren'Py `gui/` set is HD and ships in the full kit |

## What was run, and in which engine

The files for every engine are generated from the same atlas and checked against it. They were RUN in these engines:

- **Godot 4.7.2**: the demo project in godot/ was imported and run (Windows, Compatibility renderer); every themed control resolved to the kit's textures, including a table of four card Buttons, the end-turn plaque, the turn banner and three pile count badges, and the screenshot was checked. The pixel and HD themes were also assigned in a blank project to a Button, a ProgressBar (HpBar), a PanelContainer (DialogueBox), a NamePlate and the four card Buttons, whose hover, pressed (selected) and disabled styles each resolved to its own region of the atlas.

For the other engines the files are provided and checked for consistency with `atlas.json` (same regions, same 9-slice
margins); they have not been opened in that engine by us, so treat the steps below as the documented way to import them.

## Engine notes

## Godot 4 (Felt Table - Card Game and Deckbuilder UI Kit)

The `godot/` folder is a complete Godot 4 project. Open `godot/project.godot` to see every widget running before you copy
anything: the demo builds the same screen twice, once with the pixel theme and once with the HD theme.

1. Copy `godot/uikit/felt-table/` into your project (keep the folder; the themes point at
   `res://uikit/felt-table/<mode>/atlas.png`). If you move it, open each `.tres` in a text editor and change that path.
2. Assign a theme: select your root Control, set **Theme** to `uikit/felt-table/pixel/theme_pixel.tres` (pixel art games)
   or `uikit/felt-table/hd/theme_hd.tres` (high-resolution games). Every child control inherits it.
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
   in `godot/uikit/felt-table/font/` (`felt-table_pixel.tres` at size 11, `felt-table_hd.tres` at size 33, the
   same face at 3x). It needs no import step. Keep the theme's default font size (11 pixel, 33 HD): a bitmap face is
   drawn crisp at its own size. Covers printable ASCII (letters, digits, punctuation); to use your own font instead,
   set **Default Font** on the theme.

## Unity (Felt Table - Card Game and Deckbuilder UI Kit)

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

## Unreal Engine 5 (Felt Table - Card Game and Deckbuilder UI Kit)

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

## GameMaker (Felt Table - Card Game and Deckbuilder UI Kit)

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

## RPG Maker MZ (Felt Table - Card Game and Deckbuilder UI Kit)

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

## Ren'Py (Felt Table - Card Game and Deckbuilder UI Kit)

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
