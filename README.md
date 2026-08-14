# KittenHub

KittenHub is an early-stage monochrome Roblox UI library inspired by the visual language of Project Real.

The `0.2.1` visual refresh converts the Project Real / KittenHub reference into
Roblox-native UI: Fredoka One for playful display headings, Builder Sans for
interface text, and Builder Mono for values, text inputs, and keybinds.

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
- `assets/separate/*.png` — six transparent decorations, uploaded separately

Upload every PNG in `assets/separate` through Roblox Studio's Asset Manager.
Copy each image dependency/texture ID into the matching `Assets` entry. Every
decoration uses its own image ID; KittenHub no longer uses a sprite sheet or
`ImageRectOffset`/`ImageRectSize`.

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
