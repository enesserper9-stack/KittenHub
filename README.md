# KittenHub

KittenHub is an early-stage monochrome Roblox UI library inspired by the visual language of Project Real.

The `0.5.3` visual refresh converts the Project Real / KittenHub reference into
Roblox-native UI: Fredoka One for playful display headings, Builder Sans for
interface text, and Builder Mono for values, text inputs, and keybinds.

`0.5.4` is a correctness pass over that layout:

- Dropdown lists moved to an unclipped overlay layer, so they are no longer cut
  off by the content panel; they follow the button while scrolling, flip upward
  near the bottom edge, and close on outside click, tab switch, or resize.
- Sidebar, content, and footer panels use dashed outlines to match the reference.
- Section cards get explicit `LayoutOrder` values instead of relying on
  undefined tie-breaking between rows and dividers.
- Every window now owns three `UserInputService` connections total; sliders,
  keybinds, and dragging share them instead of adding their own.
- Touch input works for window dragging and sliders.
- Keybind capture ignores game-processed input (typing in a textbox no longer
  rebinds), `Escape` cancels, and `Backspace` / `Delete` clears the bind.
- Notifications no longer leak a connection per toast and cap at five on screen.
- Dashed dividers derive their dash count from the real rendered width.
- Fonts fall back to Source Sans Pro / Roboto Mono if a family is unavailable.

`0.5.5` adopts engine features that shipped after the original layout was
written, and reworks the window chrome:

- Every `UIStroke` sets `BorderStrokePosition = Inner` (released 2025-12-04).
  The default `Outer` drew each hairline outside the rounded shape, which read as
  a drawn outline rather than an inset edge.
- Panels, cards, and buttons carry a `UIGradient` inside their `UIStroke`, so the
  border catches light along its top edge and fades out at the bottom.
- The fake shadow frame is replaced by native `UIShadow` (released 2026-06-23),
  with the old frame kept as a fallback for clients that lack the class.
- Border colour moved from a solid mid grey to a light tint at high transparency,
  and every gradient ramp was flattened.
- Window controls are drawn from primitives instead of `—`, `□` and `×` glyphs,
  which never shared a baseline. Each is a 34px hit target with a hover plate;
  close tints red.
- Minimizing hides everything below the top bar instead of clipping it.
- New `Unload` asset role, used as the row icon for the unload button.

## Current preview

- Design canvas: `1280 x 760`
- Default rendered scale: `0.78`
- Separate floating sidebar and content panels
- Layered near-black gradients, restrained borders, soft shadow, and decorative pattern layer
- Responsive `UIScale` for smaller viewports
- Logo texture: `rbxassetid://102065448126548`
- Clean top bar without decorative navigation icons
- Near-black layered surfaces with restrained borders and tighter corner radii
- Fredoka One display headings, Builder Sans body text, and Builder Mono technical controls
- Window dragging, minimize, recenter, close, and RightShift visibility toggle
- Tabs and sections
- Label, button, toggle, slider, dropdown, textbox, and keybind controls
- Notification system
- Flag lookup and connection cleanup

## Files

- `KittenHub.lua` — library source
- `Example.lua` — temporary visual/API test
- `assets/*.png` — transparent KittenHub UI assets in one folder
- `assets/icon-home.png`, `icon-plus.png`, `icon-players.png`,
  `icon-settings.png`, and `icon-bell.png` — separate menu/control icons
- `assets/dark-cat-visible.png` — higher-contrast replacement for the dark cat

Upload every PNG in `assets` through Roblox Studio's Asset Manager.
Copy each image dependency/texture ID into the matching `Assets` entry. Every
decoration uses its own image ID; KittenHub no longer uses a sprite sheet or
`ImageRectOffset`/`ImageRectSize`.

The five `icon-*.png` files must be uploaded separately. Paste their IDs into
`Home`, `Plus`, `Players`, `Settings`, and `Bell`. Upload
`dark-cat-visible.png` separately and replace the existing `DarkCat` ID.

### If the sprites appear blank

1. Wait until the image thumbnail is visible and moderation has completed.
2. In Creator Dashboard, open the image's **Permissions / Asset Access** page.
3. If testing inside an experience you don't own, set the image to **Open Use**.
4. Use each upload's image dependency/texture ID, not its parent asset/decal ID.

KittenHub preloads the sheet and prints a warning in the Developer Console when
Roblox denies or fails to load it. A glyph fallback is displayed instead of an
empty square.

`Example.lua` loads the library from the KittenHub GitHub repository. Push the
updated `KittenHub.lua` before testing that raw URL.

## Example API

```lua
local Window = KittenHub:CreateWindow({
    Title = "KittenHub",
    Icon = "rbxassetid://102065448126548",
    Size = Vector2.new(1280, 760),
    Scale = 0.78,
    Assets = {
        Logo = "rbxassetid://102065448126548",
        Paw = "rbxassetid://131136157222328",
        Heart = "rbxassetid://107252414250704",
        Sleeping = "rbxassetid://112356892711029",
        Peek = "rbxassetid://133697879389288",
        Curled = "rbxassetid://101414414893719",
        DarkCat = "rbxassetid://118910476036241",
        DropdownCat = "rbxassetid://98425969504037",
        Sparkles = "rbxassetid://114850152769331",
        Home = "rbxassetid://118174015024924",
        Plus = "rbxassetid://98329354716868",
        Players = "rbxassetid://125376145853165",
        Settings = "rbxassetid://87200505076227",
        Bell = "rbxassetid://80479928306450",
    },
})

local Tab = Window:AddTab({ Name = "New Tab", Icon = "+", IconRole = "Plus" })
local Section = Tab:AddSection("Example")

Section:AddToggle({
    Text = "Toggle",
    Default = false,
    Flag = "ToggleFlag",
    Callback = function(value)
        print(value)
    end,
})
```
