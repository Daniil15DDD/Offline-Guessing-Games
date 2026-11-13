import Foundation

/// TEMPORARY test scaffolding for simulator screenshots. Removed after use.
enum DemoMode {
    static func flag(_ name: String) -> Bool {
        UserDefaults.standard.string(forKey: "demo") == name
    }

    static func fourfold(_ mode: PlayMode) -> FourfoldGame {
        let game = FourfoldGame(mode: mode)
        guard flag("over") else { return game }
        let groups = game.puzzle.groups
        (Array(groups[0].words.prefix(3)) + [groups[1].words[0]]).forEach(game.toggle)
        game.submit()
        game.clearSelection()
        for group in groups {
            group.words.forEach(game.toggle)
            game.submit()
        }
        return game
    }

    static func price(_ mode: PlayMode) -> PriceGame {
        let game = PriceGame(mode: mode)
        guard flag("finished") else { return game }
        for _ in 0..<PriceGame.rounds {
            game.guess(game.item.price * 0.9)
            game.guess(game.item.price)
            game.next()
        }
        return game
    }
}
