import Foundation

/// TEMPORARY test scaffolding: with the launch argument `-demo YES` each game
/// opens part-way through a round, so the simulator screenshots show the
/// mid-game layouts. Removed again after checking.
enum DemoMode {
    static var isOn: Bool { UserDefaults.standard.bool(forKey: "demo") }

    static func globe() -> GlobeGame {
        let game = GlobeGame()
        guard isOn else { return game }
        for name in ["Brazil", "Germany", "Japan", "Kenya", "India", "Canada", "Egypt"] {
            if let country = Atlas.countries.first(where: { $0.name == name && $0.id != game.target.id }) {
                game.guess(country)
            }
        }
        return game
    }

    static func fourfold() -> FourfoldGame {
        let game = FourfoldGame()
        guard isOn else { return game }
        game.puzzle.groups[0].words.forEach(game.toggle)
        game.submit()
        let wrong = Array(game.puzzle.groups[1].words.prefix(3)) + [game.puzzle.groups[2].words[0]]
        wrong.forEach(game.toggle)
        game.submit()
        return game
    }

    static func topTen() -> TopTenGame {
        let game = TopTenGame()
        guard isOn else { return game }
        for index in [0, 3, 7] { game.submit(game.list.entries[index].name) }
        game.submit("Atlantis")
        game.submit("Narnia")
        return game
    }

    static func critter() -> CritterGame {
        let game = CritterGame()
        guard isOn else { return game }
        for index in [1, 39, 47, 54] where Critters.all[index].id != game.target.id {
            game.guess(Critters.all[index])
        }
        return game
    }

    static func rare() -> RareGame {
        let game = RareGame()
        guard isOn else { return game }
        // Two prompts answered, third one showing its reveal.
        for tier in [3, 5, 4] {
            if let answer = game.prompt.answers.first(where: { $0.tier == tier }) ?? game.prompt.answers.last {
                game.submit(answer.name)
            }
            if tier != 4 { game.next() }
        }
        return game
    }

    static func price() -> PriceGame {
        let game = PriceGame()
        guard isOn else { return game }
        game.guess(game.item.price * 2)
        game.guess(game.item.price * 0.85)
        return game
    }

    static func ballpark() -> BallparkGame {
        let game = BallparkGame()
        guard isOn else { return game }
        game.lockIn(game.question.answer * 3)
        return game
    }

    static func trend() -> TrendGame {
        let game = TrendGame()
        guard isOn else { return game }
        let real = Array(game.series.values.suffix(game.series.hiddenCount))
        let last = game.series.values[game.series.shown - 1]
        for (index, value) in real.enumerated() {
            game.setValue(last + (value - last) * 0.6, at: index)
        }
        game.submit()
        return game
    }

    static func scale() -> ScaleGame {
        let game = ScaleGame()
        guard isOn else { return game }
        game.lockIn()
        return game
    }

    static func hue() -> HueGame {
        let game = HueGame()
        guard isOn else { return game }
        let now = Date()
        game.tick(now: now)
        game.tick(now: now.addingTimeInterval(10))
        return game
    }

    static func pitch() -> PitchGame {
        let game = PitchGame()
        guard isOn else { return game }
        game.lockIn()
        return game
    }

    static func beat() -> BeatGame {
        let game = BeatGame()
        guard isOn else { return game }
        game.startListening()
        game.finishListening()
        for index in 0..<BeatGame.tapsNeeded {
            game.tap(at: 1 + Double(index) * game.interval * 1.06)
        }
        return game
    }
}
