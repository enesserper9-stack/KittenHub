# KittenHub

KittenHub is an early-stage monochrome Roblox UI library inspired by the visual language of Project Real.

The `0.2.0` visual refresh converts the Project Real / KittenHub reference into
Roblox-native UI: Fredoka One for playful display headings, Builder Sans for
interface text, and Builder Mono for values, text inputs, and keybinds.

## Current preview

- Design canvas: `1280 x 760`
- Default rendered scale: `0.78`
- Separate floating sidebar and content panels
- Layered near-black gradients, restrained borders, soft shadow, and decorative pattern layer
- Responsive `UIScale` for smaller viewports
- Asset: `rbxassetid://89700767026016`
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
- `assets/kitten-sprites.png` — transparent 3×2 decoration sprite sheet

Upload `assets/kitten-sprites.png` through Roblox Studio's Asset Manager, copy
the resulting image asset ID, and set `Assets.SpriteSheet`. KittenHub uses
predefined `ImageRectOffset`/`ImageRectSize` rectangles to render all six
decorations from that single uploaded image.

### If the sprites appear blank

1. Wait until the image thumbnail is visible and moderation has completed.
2. In Creator Dashboard, open the image's **Permissions / Asset Access** page.
3. If testing inside an experience you don't own, set the image to **Open Use**.
4. Keep the code value in the form `rbxassetid://75770413731434`.

KittenHub preloads the sheet and prints a warning in the Developer Console when
Roblox denies or fails to load it. A glyph fallback is displayed instead of an
empty square.

`Example.lua` contains a placeholder URL. Replace `YOUR_RAW_KITTENHUB_URL_HERE` after the library is uploaded to a raw file host or GitHub repository.

## Example API

```lua
local Window = KittenHub:CreateWindow({
    Title = "KittenHub",
    Icon = "rbxassetid://89700767026016",
    Size = Vector2.new(1280, 760),
    Scale = 0.78,
    Assets = {
		SpriteSheet = "rbxassetid://75770413731434",
        Logo = "rbxassetid://89700767026016",
        RowIcon = "rbxassetid://89700767026016",
        -- Paw = "rbxassetid://YOUR_PAW_ASSET",
        -- Heart = "rbxassetid://YOUR_HEART_ASSET",
        -- CornerCat = "rbxassetid://YOUR_CORNER_CAT_ASSET",
    },
})

local Tab = Window:AddTab({ Name = "New Tab", Icon = "+" })
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
