# Mini Game Hub

An iPhone app with three small games behind one menu. It is written in Swift
with SwiftUI (menu, score bar, overlays) and SpriteKit (the games). It needs no
network, no accounts and no third-party code. There are no image or sound
files: everything on screen is drawn in code.

| Game | Type | Controls |
| --- | --- | --- |
| Moon Dash | Endless runner | Tap to jump. Hold longer for a higher jump. Tap again in the air for a double jump. Run under the high drones, jump everything else. |
| Tile Fuse | Sliding number puzzle on a 4 x 4 grid | Swipe to slide all tiles. Two equal tiles that meet fuse into one worth double. Undo takes back one move. |
| Neon Snake | Snake | Swipe to steer. Eat to grow. Walls and your own body end the run. |

These are original takes on three well-known game genres, with their own
names, art and tuning, not copies of any specific existing game.

## Run it

Requirements: a Mac with Xcode 15 or later. The app targets iOS 16 and later.

### Option A: open the included project

1. Download or clone this repository.
2. Open `MiniGameHub.xcodeproj` in Xcode.
3. Pick an iPhone simulator in the toolbar and press Run (Cmd+R).

To run on a real iPhone, select the `MiniGameHub` target, open
**Signing & Capabilities**, choose your Team, and change the bundle identifier
from `com.example.MiniGameHub` to something of your own.

### Option B: paste one file into a new project

Use this if the included project gives you any trouble.

1. In Xcode choose **File > New > Project > iOS > App**. Interface: SwiftUI.
   Language: Swift.
2. Delete the two Swift files Xcode created (`ContentView.swift` and
   `<YourProjectName>App.swift`).
3. Drag `CopyPaste/MiniGameHubAllInOne.swift` into the project (tick
   "Copy items if needed"), or create a new Swift file and paste its contents.
4. Make sure the target's minimum deployment is iOS 16 or later, then press Run.

Instead of the single file you can also drag the whole `MiniGameHub` folder
into the new project. Do one or the other, not both.

## How it fits together

```
MiniGameHub/
  MiniGameHubApp.swift        App entry point, portrait lock
  Hub/HubView.swift           Main menu: one card per game, best scores, settings
  Shared/
    GameKind.swift            The list of games (title, colours, score key)
    GameSession.swift         Score and phase shared by a scene and its screen
    GameScreen.swift          Score bar, pause / game over overlays, score saving
    HighScoreStore.swift      Offline high scores
    Theme.swift, Haptics.swift
  Logic/                      Game rules with no drawing code
    MergeBoard.swift          Tile Fuse rules
    SnakeEngine.swift         Neon Snake rules
    MoveDirection.swift
  Games/
    MoonDash/                 RunnerScene (SpriteKit) + RunnerGameView (SwiftUI)
    TileFuse/                 MergeScene + MergeGameView
    NeonSnake/                SnakeScene + SnakeGameView
CopyPaste/                    The same code as a single file (generated)
Tests/LogicTests/             Command-line checks for the game rules
```

**Navigation.** `HubView` holds a `NavigationStack`. Tapping a card pushes that
game's view. Each game view wraps its SpriteKit scene in `GameScreen`, which
draws the score bar and the overlays and has the back button.

**Scene and screen.** A scene never talks to SwiftUI directly. It reads and
writes a `GameSession` (score plus a phase: ready, playing, paused, game over),
and `GameScreen` observes it.

**High scores.** `HighScoreStore` keeps one best score per game in
`UserDefaults`, which lives on the device and needs no network. `GameScreen`
submits the score when a game ends, when you leave the screen, and when the app
goes to the background. Tile Fuse also saves the board after every move, so a
game in progress is still there when you come back.

**Adding a game.** Add a case to `GameKind`, write a scene that conforms to
`HubGameScene`, wrap it like the existing `*GameView` files, and add it to the
`switch` in `HubView`.

## What was tested, and what was not

This code was written on Linux, where Xcode and the iOS frameworks do not
exist. It has **not** been compiled by Xcode or run on a simulator or device.
If the first build shows an error, it is most likely a small API detail that
could not be checked here.

What was checked:

- The game rules in `Logic/` are compiled and tested with the real Swift
  compiler (`Tests/LogicTests`). All checks pass.
- All Swift files type-check against hand-written stand-ins for SwiftUI,
  SpriteKit and UIKit. This catches mistakes inside this code base, but not a
  wrong assumption about an Apple API.
- The three scenes were played headlessly by bots on those stand-ins, across
  several screen sizes, for thousands of rounds, checking for crashes, score
  and state mistakes, and leftover nodes. This also tuned Moon Dash: a bot
  with 300 to 400 ms reactions survives roughly 60 to 85 seconds.
- `project.pbxproj` parses as a valid project file and every file reference in
  it points at a real file.

To run the rule tests yourself (any Mac with Xcode, from the repository root):

```
swiftc -swift-version 5 MiniGameHub/Logic/*.swift Tests/LogicTests/main.swift -o logic-tests
./logic-tests
```

## Tips

- Launch argument `-startGame runner` (or `merge`, `snake`) opens a game
  directly. Set it under **Product > Scheme > Edit Scheme > Run > Arguments**.
- The Haptics switch and the "Reset high scores" button are at the bottom of
  the menu.
- After changing files in `MiniGameHub/`, run `python3 CopyPaste/regenerate.py`
  to rebuild the single-file version.
