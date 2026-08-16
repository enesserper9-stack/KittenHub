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

`0.5.11` adds alternate icon roles:

- `CrossedRifles` and `Shield` join `DefaultAssets`. No control reaches for them
  on its own — they are there so a script can pick a subject-matching icon via
  `IconRole` instead of a generic paw.
- `CreateWindow` fills missing roles by iterating `DefaultAssets` rather than
  assigning them one by one, so a newly added default is available immediately.

`0.5.10` opts out of automatic localization:

- Every GUI object the library creates sets `AutoLocalize = false`. Roblox
  translates in-experience text when the client's language differs from the
  experience's, so a dropdown offering `Head` rendered as `Kafa` on a Turkish
  client while the value behind it was still `Head`. Control names are part of
  the API surface and must read the same on every client.

`0.5.9` rebuilds the dropdown list:

- Option rows were bare text with a hover tint and no marker for the current
  value. Each row now carries a left accent bar, a drawn check, and a weight and
  colour change when selected, plus a small indent on hover so it reads as a
  target rather than a line of text.
- Long lists scroll instead of growing past the viewport: the options sit in a
  `ScrollingFrame` with `AutomaticSize` capped by a `UISizeConstraint` (246px),
  which is the pattern Roblox's layout guidance recommends for overflow.
- Option text moves to 16px Nunito, medium for unselected rows and semibold for
  the selected one.

`0.5.8` simplifies the line work:

- Dashed rules and dashed panel outlines are gone. Both were built from dozens of
  separate 1px frames, which read as rows of bright specks rather than as lines
  and cost 40+ instances per divider. Panels keep their `UIStroke` edge, and the
  page and content dividers are one solid grey frame each.
- The `⋮` overflow marker at the end of the sidebar footer is removed; it opened
  nothing and the rounded font drew it as a smudge.

`0.5.7` is a typography and contrast pass:

- Interface text moves from Builder Sans to Nunito. The neutral grotesk did not
  belong next to Fredoka One's round display letters, and its thin strokes washed
  out at 14-18px on near-black. Weights step up one notch each (body is Medium,
  titles are Bold), and slider readouts use the rounded face instead of mono.
- Surfaces step apart in grey — window, panel, card, and control each sit on
  their own level — and gradient ramps carry real contrast instead of two shades
  of the same black.
- Hairline transparencies moved into one `Line` table and were pulled back from
  0.74-0.9 to 0.44-0.56, so panel edges survive against the dark background.
  Dividers and dashes lightened to match.
- The sidebar footer shows the running library version instead of "Signed in",
  which also makes a stale cached copy obvious. `UserStatus` still overrides it.
- Glyph placeholders no longer strand themselves on top of a loaded image. The
  countdown runs only while a label is actually on screen, so icons on unopened
  tabs stay clean, and the watcher no longer gives up on an asset that is simply
  slow.

`0.5.6` is a correctness and cost pass:

- `PageTitle` is no longer accepted and ignored. On `CreateWindow` it names the
  landing page; `AddTab { PageTitle = ... }` overrides it per tab, and
  `Tab:SetPageTitle(text)` changes it afterwards.
- Sliders snap from `Min` rather than from zero (a `5..105` slider stepping by
  `10` lands on 5, 15, 25) and the snapped value is rounded to the increment's
  own decimal count, so `0.1` steps no longer print `0.30000000000000004`.
- `Dropdown:Refresh` disconnects the option rows it destroys. Each dropdown owns
  its option connections instead of appending dead entries to the window list.
- Unloaded images share one watcher coroutine instead of one per icon (~60 idle
  threads per window before), and entries drop as soon as the image loads or its
  window is destroyed.
- The content footer divider anchors to the panel's bottom edge instead of the
  design canvas height minus a constant, which drifted at custom window sizes.
- `Window:Destroy` tears down dropdown option connections, not just popups.

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
