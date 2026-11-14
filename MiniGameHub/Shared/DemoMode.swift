import SwiftUI

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

    static func globe(_ mode: PlayMode) -> GlobeGame {
        let game = GlobeGame(mode: mode)
        guard flag("guesses") else { return game }
        for name in ["Brazil", "France", "India", "Kenya", "Canada"] {
            if let country = Atlas.countries.first(where: { $0.name == name }), country.id != game.target.id {
                game.guess(country)
            }
        }
        return game
    }

    static func critter(_ mode: PlayMode) -> CritterGame {
        let game = CritterGame(mode: mode)
        guard flag("guesses") else { return game }
        for critter in Critters.all.prefix(12) where critter.name != game.target.name && game.rows.count < 3 {
            game.guess(critter)
        }
        return game
    }

    static func topTen(_ mode: PlayMode) -> TopTenGame {
        let game = TopTenGame(mode: mode)
        guard flag("guesses") else { return game }
        for index in [0, 3, 6] {
            _ = game.submit(game.list.entries[index].name)
        }
        _ = game.submit("zzzz")
        return game
    }

    static func scale(_ mode: PlayMode) -> ScaleGame {
        let game = ScaleGame(mode: mode)
        guard flag("reveal") else { return game }
        game.slider = 0.42
        game.lockIn()
        return game
    }
}

/// Every outline Scale It can draw, to check them by eye.
struct SilhouetteGallery: View {
    let page: Int

    private var members: [ScalePairs.Member] {
        var seen = Set<String>()
        var result: [ScalePairs.Member] = []
        for family in ScalePairs.families {
            for member in family.members where !seen.contains(member.outline) {
                seen.insert(member.outline)
                result.append(member)
            }
        }
        return result
    }

    var body: some View {
        let all = members
        let perPage = 35
        let slice = Array(all.dropFirst(page * perPage).prefix(perPage))
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 8) {
            ForEach(slice, id: \.outline) { member in
                VStack(spacing: 3) {
                    let aspect = Silhouettes.aspect(for: member.outline)
                    SilhouetteView(key: member.outline, height: min(66, 66 / max(aspect, 0.01)), color: GameKind.scale.accent)
                        .frame(width: 70, height: 68, alignment: .bottom)
                    Text(member.name)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
