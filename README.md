# KittenHub

KittenHub is an early-stage monochrome Roblox UI library inspired by the visual language of Project Real.

## Current preview

- Base window: `1248 x 687`
- Sidebar: `252 px`
- Sidebar controls: about `221 px`
- Responsive `UIScale` for smaller viewports
- Asset: `rbxassetid://89700767026016`
- Window dragging, minimize, recenter, close, and RightShift visibility toggle
- Tabs and sections
- Label, button, toggle, slider, dropdown, textbox, and keybind controls
- Notification system
- Flag lookup and connection cleanup

## Files

- `KittenHub.lua` — library source
- `Example.lua` — temporary visual/API test

`Example.lua` contains a placeholder URL. Replace `YOUR_RAW_KITTENHUB_URL_HERE` after the library is uploaded to a raw file host or GitHub repository.

## Example API

```lua
local Window = KittenHub:CreateWindow({
    Title = "KittenHub",
    Icon = "rbxassetid://89700767026016",
    Size = Vector2.new(1248, 687),
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
