# Offline Guessing Games

An iPhone app with twelve small guessing games behind one menu. It is written
in Swift and SwiftUI, needs no network and no accounts, and uses no
third-party code. Every puzzle ships inside the app.

Each game is an original take on a popular style of web guessing game, with
its own name, rules text, look and content. None of them copies the puzzles,
data, images or branding of an existing game.

## The games

| Game | How it plays | One run | Max |
| --- | --- | --- | --- |
| Borderline | Name the country from its outline. Each guess shows the distance and direction to the answer. | 3 countries, 6 guesses each | 300 |
| Fourfold | Sort sixteen words into four hidden groups of four. Four mistakes allowed. | 1 puzzle | 500 |
| Ten Count | Name everything on a top-ten list before five wrong guesses. | 1 list | 100 |
| Critter Clues | Find the mystery animal. Each guess shows which traits match. | 1 animal, 8 guesses | 100 |
| Rare Find | Seven timed "name a ..." prompts. Less obvious answers score more. | 7 prompts, 25 seconds each | 700 |
| Price Point | Guess what an everyday item costs, with higher or lower hints. | 3 items, 6 guesses each | 300 |
| Ballpark | Estimate a big number in one guess. Scored by how many times off you were. | 3 questions | 300 |
| Trendline | The start of a real chart is shown. Draw where the line went next. | 3 charts | 300 |
| Scale It | Resize one thing until it is the right size next to another. | 5 pairs | 500 |
| Hue Recall | Study a colour for three seconds, then rebuild it with sliders. | 5 colours | 500 |
| Pitch Match | Listen to a note, then tune your own note to match. | 5 notes | 500 |
| Beat Keeper | Listen to a beat, then keep it going by tapping. | 5 beats | 500 |

Puzzles are dealt from a shuffled deck that is remembered between launches,
so you see every puzzle in a game once before any repeats.

## Run it

Requirements: a Mac with Xcode 15 or later. The app targets iOS 16 and later.

1. Download or clone this repository.
2. Open `MiniGameHub.xcodeproj` in Xcode.
3. Pick an iPhone simulator in the toolbar and press Run (Cmd+R).

To run on a real iPhone, select the `MiniGameHub` target, open
**Signing & Capabilities**, choose your Team, and change the bundle identifier
from `com.example.MiniGameHub` to something of your own.

Pitch Match and Beat Keeper play sound, so turn the volume up for those.

## How it fits together

```
MiniGameHub/
  MiniGameHubApp.swift     App entry point, portrait lock
  Hub/HubView.swift        Main menu: one card per game, best scores, settings
  Shared/
    GameKind.swift         The list of games (title, colours, max score)
    GameChrome.swift       Top bar, result panel, score saving, shared styles
    HighScoreStore.swift   Offline high scores
    TonePlayer.swift       Sine tones for the two sound games
    Theme.swift, Haptics.swift
  Logic/                   Rules shared by several games (no screen code)
    TextMatch.swift        Forgiving matching of typed answers
    Geo.swift              Distance and direction between two places
    Scoring.swift          Point rules
    Deck.swift             Shuffled, remembered puzzle order
    Atlas.swift            Reads the country outlines
  Data/                    All puzzle content, one file per game
  Models/                  One engine per game: its state and rules
  Games/                   One SwiftUI screen per game
Tests/LogicTests/          Command-line checks for the rules and content
```

**Navigation.** `HubView` holds a `NavigationStack`. Tapping a card pushes that
game's screen. Every screen is wrapped in `GameChrome`, which draws the top bar
and the result panel and has the back button.

**Engine and screen.** Each game has an engine in `Models/` (an
`ObservableObject` holding the state and rules) and a screen in `Games/` that
only draws that state and passes taps along. The engines do not import SwiftUI,
which is what lets the tests run them from the command line.

**High scores.** `HighScoreStore` keeps one best score per game in
`UserDefaults`, which lives on the device and needs no network. `GameChrome`
submits the score when a run ends and when you leave a game part-way.

**Adding a game.** Add a case to `GameKind`, write an engine and a screen, and
add the screen to the `switch` in `HubView`.

## About the content

- **Country outlines** come from Natural Earth (public domain,
  naturalearthdata.com) at 1:110m scale. The game uses the 165 United Nations
  member states present in that data. Far-off overseas territories and very
  small islands are left out of the outlines.
- **Ten Count lists, Ballpark answers, Scale It sizes and Trendline charts**
  are standard reference figures and official statistics. The lists are
  limited to rankings that do not change from year to year.
- **Price Point prices** are rough reference prices for a typical mid-range
  item in a US shop, chosen for the game. They are not live prices and do not
  come from any particular shop. Change them in `Data/PriceItems.swift`.
- **Rare Find tiers** are the author's estimate of how obvious each answer
  is. Online games of this kind rank answers by what real players type, which
  an offline app cannot do. Change them in `Data/RarePrompts.swift`.
- **Fourfold puzzles and Critter Clues animals** were written for this app.

## Testing

Every push to a `claude/**` branch or a pull request runs
`.github/workflows/ios-build.yml` on GitHub, which runs the rule and content
checks and builds the app with Xcode for the iOS Simulator.

To run the checks yourself from the repository root on a Mac:

```
swiftc -swift-version 5 MiniGameHub/Logic/*.swift MiniGameHub/Data/*.swift \
    MiniGameHub/Models/*.swift Tests/LogicTests/main.swift -o logic-tests
./logic-tests
```

They cover the answer matching, the geography maths, the scoring, every game
engine played through from start to finish, and the content itself (for
example that every Fourfold puzzle has sixteen different words, that every
accepted spelling in a list resolves to the right entry, and that no two
animals look identical to the clue system).

## Tips

- Launch argument `-startGame borderline` (or `fourfold`, `topTen`, `critter`,
  `rare`, `price`, `ballpark`, `trend`, `scale`, `hue`, `pitch`, `beat`) opens
  a game directly. Set it under **Product > Scheme > Edit Scheme > Run >
  Arguments**.
- The Haptics switch and the "Reset high scores" button are at the bottom of
  the menu.
