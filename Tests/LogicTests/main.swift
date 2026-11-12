// Command-line checks for the game rules and the puzzle content.
// No Xcode project needed. From the repository root on a Mac:
//
//   swiftc -swift-version 5 MiniGameHub/Logic/*.swift MiniGameHub/Data/*.swift \
//       MiniGameHub/Models/*.swift Tests/LogicTests/main.swift -o logic-tests
//   ./logic-tests

import Foundation

var failures = 0
var checks = 0

func expect(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, line: UInt = #line) {
    checks += 1
    if !condition() {
        failures += 1
        if failures <= 60 {
            print("FAIL (line \(line)): \(message())")
        }
    }
}

// Keep the real puzzle decks untouched by these tests.
let deckKeys = ["borderline", "fourfold", "topten", "critters", "prices", "rare", "ballpark", "trend", "scale", "test"]
func resetDecks() {
    for key in deckKeys {
        UserDefaults.standard.removeObject(forKey: "deck." + key)
    }
}
resetDecks()

// MARK: - Text matching

expect(TextMatch.normalize("  The  Côte d'Ivoire! ") == "cotedivoire", "normalize folds accents and punctuation")
expect(TextMatch.normalize("St. Bernard") == "saintbernard", "st becomes saint")
expect(TextMatch.normalize("Trinidad & Tobago") == "trinidadandtobago", "ampersand becomes and")
expect(TextMatch.editDistance("kitten", "sitting") == 3, "edit distance")
expect(TextMatch.editDistance("", "abc") == 3, "edit distance with empty text")
do {
    let options = [["Iran"], ["Iraq"], ["Kangchenjunga"], ["Niger"], ["Nigeria"], ["John Adams", "Adams"], ["John Quincy Adams"]]
    expect(TextMatch.bestMatch("iran", in: options) == 0, "exact match")
    expect(TextMatch.bestMatch("Irak", in: options) == nil, "short words allow no typos")
    expect(TextMatch.bestMatch("kanchenjunga", in: options) == 2, "long words allow typos")
    expect(TextMatch.bestMatch("Niger", in: options) == 3, "exact beats near")
    expect(TextMatch.bestMatch("Nigeria", in: options) == 4, "exact beats near, longer")
    expect(TextMatch.bestMatch("adams", in: options) == 5, "alias")
    expect(TextMatch.bestMatch("john quincy adams", in: options) == 6, "full name")
    expect(TextMatch.bestMatch("   ", in: options) == nil, "blank input")
    expect(TextMatch.bestMatch("zzzz", in: options) == nil, "nonsense")
    expect(TextMatch.suggestions(for: "ni", in: options, limit: 5) == [3, 4], "prefix suggestions")
}

// MARK: - Geography

do {
    // London to Paris is about 344 km.
    let km = Geo.distanceKm(lat1: 51.5074, lon1: -0.1278, lat2: 48.8566, lon2: 2.3522)
    expect(abs(km - 344) < 5, "London to Paris distance, got \(km)")
    let north = Geo.bearing(lat1: 0, lon1: 0, lat2: 10, lon2: 0)
    let east = Geo.bearing(lat1: 0, lon1: 0, lat2: 0, lon2: 10)
    let southWest = Geo.bearing(lat1: 10, lon1: 10, lat2: 0, lon2: 0)
    expect(abs(north) < 0.01 && Geo.compass(north) == "N", "bearing north")
    expect(abs(east - 90) < 0.01 && Geo.compass(east) == "E", "bearing east")
    expect(Geo.compass(southWest) == "SW", "bearing south-west, got \(southWest)")
    expect(Geo.compass(359.9) == "N" && Geo.compass(337.4) == "NW", "compass wraps")
    expect(Geo.proximity(km: 0) == 100 && Geo.proximity(km: 30000) == 0, "proximity range")
}

// MARK: - Scoring and numbers

expect(Scoring.ladder(attempt: 1, maxAttempts: 6) == 100, "ladder first try")
expect(Scoring.ladder(attempt: 6, maxAttempts: 6) == 17, "ladder last try")
expect(Scoring.ladder(attempt: 7, maxAttempts: 6) == 0, "ladder past the end")
expect(Scoring.closeness(error: 0, perfect: 0.1, zero: 1) == 100, "closeness perfect")
expect(Scoring.closeness(error: 0.55, perfect: 0.1, zero: 1) == 50, "closeness halfway")
expect(Scoring.closeness(error: 2, perfect: 0.1, zero: 1) == 0, "closeness far")
expect(Scoring.closeness(error: .nan, perfect: 0.1, zero: 1) == 0, "closeness not a number")
expect(Scoring.estimate(guess: 100, answer: 100) == 100, "estimate exact")
expect(Scoring.estimate(guess: 10, answer: 100) == 50, "estimate ten times low")
expect(Scoring.estimate(guess: 1000, answer: 100) == 50, "estimate ten times high")
expect(Scoring.estimate(guess: 1, answer: 1_000_000) == 0, "estimate hopeless")
expect(Scoring.estimate(guess: 0, answer: 5) == 0, "estimate zero guess")
expect(NumberText.plain(384_400) == "384,400", "plain thousands, got \(NumberText.plain(384_400))")
expect(NumberText.plain(149_600_000) == "149.6 million", "plain millions, got \(NumberText.plain(149_600_000))")
expect(NumberText.plain(9_461_000_000_000) == "9.46 trillion", "plain trillions, got \(NumberText.plain(9_461_000_000_000))")
expect(NumberText.plain(3.5) == "3.5" && NumberText.plain(88) == "88", "plain small numbers")
expect(NumberText.plain(8_000_000) == "8,000,000", "plain single millions stay as digits")
expect(NumberText.factor(1) == "spot on" && NumberText.factor(2.345) == "2.35x off", "factor text, got \(NumberText.factor(2.345))")
expect(NumberText.parse("1,250.5") == 1250.5 && NumberText.parse("$40") == 40, "parse typed numbers")
expect(NumberText.parse("") == nil && NumberText.parse("abc") == nil, "parse rejects junk")

// MARK: - Deck

do {
    var seen: [Int] = []
    for _ in 0..<10 { seen.append(Deck.next("test", count: 10)) }
    expect(Set(seen).count == 10, "a deck deals every card before repeating")
    let hand = Deck.draw("test", count: 10, take: 4)
    expect(hand.count == 4 && Set(hand).count == 4, "draw gives different cards")
    expect(Deck.draw("test", count: 2, take: 5).count == 2, "draw never exceeds the deck")
    expect(Deck.next("test", count: 0) == 0, "empty deck is safe")
}

// MARK: - Content checks

do {
    let countries = Atlas.countries
    expect(countries.count == 165, "165 countries, got \(countries.count)")
    expect(Set(countries.map(\.name)).count == countries.count, "country names are unique")
    for country in countries {
        expect(!country.rings.isEmpty && country.rings.allSatisfy { $0.count >= 3 }, "\(country.name) has an outline")
        expect(abs(country.latitude) <= 90 && abs(country.longitude) <= 180, "\(country.name) centre is on the globe")
        let found = TextMatch.bestMatch(country.name, in: countries.map(\.spellings))
        expect(found == country.id, "\(country.name) can be typed")
    }
    for name in Atlas.aliases.keys {
        expect(countries.contains { $0.name == name }, "alias key \(name) is a country")
    }
    for (name, aliases) in Atlas.aliases {
        for alias in aliases {
            let index = TextMatch.bestMatch(alias, in: countries.map(\.spellings))
            expect(index != nil && countries[index!].name == name, "alias \(alias) finds \(name)")
        }
    }
}

for (number, puzzle) in GroupPuzzles.all.enumerated() {
    expect(puzzle.groups.count == 4, "puzzle \(number) has four groups")
    expect(puzzle.groups.allSatisfy { $0.words.count == 4 }, "puzzle \(number) groups have four words")
    expect(Set(puzzle.words).count == 16, "puzzle \(number) has sixteen different words")
    expect(puzzle.words.allSatisfy { $0 == $0.uppercased() && $0.count <= 11 }, "puzzle \(number) words fit a tile")
}
expect(GroupPuzzles.all.count >= 20, "at least twenty word puzzles")

for list in TopTenLists.all {
    expect(list.entries.count == 10, "\(list.title) has ten entries")
    let options = list.entries.map(\.spellings)
    for (index, entry) in list.entries.enumerated() {
        for spelling in entry.spellings {
            expect(TextMatch.bestMatch(spelling, in: options) == index, "\(list.title): \(spelling) finds its entry")
        }
    }
}

do {
    let critters = Critters.all
    expect(critters.count >= 50, "at least fifty animals")
    expect(Set(critters.map(\.name)).count == critters.count, "animal names are unique")
    let groups: Set<String> = ["Mammal", "Bird", "Reptile", "Amphibian", "Fish", "Invertebrate"]
    let diets: Set<String> = ["Herbivore", "Carnivore", "Omnivore"]
    let homes: Set<String> = ["Land", "Water", "Both"]
    let regions: Set<String> = ["Africa", "Asia", "Europe", "North America", "South America", "Oceania", "Antarctica", "Oceans"]
    for critter in critters {
        expect(groups.contains(critter.group), "\(critter.name) group")
        expect(diets.contains(critter.diet), "\(critter.name) diet")
        expect(homes.contains(critter.home), "\(critter.name) home")
        expect(!critter.regions.isEmpty && critter.regions.allSatisfy(regions.contains), "\(critter.name) regions \(critter.regions)")
        expect(critter.legs >= 0 && critter.weightKg > 0, "\(critter.name) numbers")
    }
    // No two animals may look identical to the clue system.
    for a in critters {
        for b in critters where a.id < b.id {
            let row = CritterGame.compare(a, to: b, id: 0)
            let identical = [row.group, row.diet, row.home, row.legs, row.regions, row.weight].allSatisfy { $0 == .match }
            expect(!identical, "\(a.name) and \(b.name) can be told apart")
        }
    }
}

expect(PriceItems.all.count >= 40 && PriceItems.all.allSatisfy { $0.price > 0 }, "price items are valid")
expect(Set(PriceItems.all.map(\.name)).count == PriceItems.all.count, "price item names are unique")

for prompt in RarePrompts.all {
    let options = prompt.answers.map(\.spellings)
    expect(prompt.answers.allSatisfy { (1...5).contains($0.tier) }, "\(prompt.text): tiers in range")
    expect(prompt.answers.contains { $0.tier == 5 } && prompt.answers.contains { $0.tier == 1 }, "\(prompt.text): has common and rare answers")
    var seen: [String: Int] = [:]
    for (index, answer) in prompt.answers.enumerated() {
        for spelling in answer.spellings {
            let key = TextMatch.normalize(spelling)
            expect(!key.isEmpty, "\(prompt.text): empty spelling")
            if let other = seen[key], other != index {
                expect(false, "\(prompt.text): \(spelling) is listed twice")
            }
            seen[key] = index
            expect(TextMatch.bestMatch(spelling, in: options) == index, "\(prompt.text): \(spelling) finds its answer")
        }
    }
}
expect(RarePrompts.all.count >= 21, "enough prompts for three different runs")

expect(BallparkQuestions.all.allSatisfy { $0.answer > 0 && !$0.unit.isEmpty }, "ballpark answers are valid")
expect(Set(BallparkQuestions.all.map(\.text)).count == BallparkQuestions.all.count, "ballpark questions are unique")

for series in TrendSeriesData.all {
    expect(series.years.count == series.values.count, "\(series.title): one value per year")
    expect(series.shown >= 3 && series.hiddenCount >= 3, "\(series.title): enough shown and hidden points")
    expect(series.values.allSatisfy { $0 >= series.axisMin && $0 <= series.axisMax }, "\(series.title): values fit the axis")
    expect(zip(series.years, series.years.dropFirst()).allSatisfy { $0 < $1 }, "\(series.title): years ascend")
    // The real data must score 100 against itself.
    let perfect = Array(series.values.suffix(series.hiddenCount))
    expect(TrendGame.gap(drawn: perfect, series: series) == 0, "\(series.title): perfect drawing has no gap")
}

for pair in ScalePairs.all {
    expect(pair.ratio >= ScalePairs.minRatio && pair.ratio <= ScalePairs.maxRatio, "\(pair.referenceName) vs \(pair.targetName) fits the slider")
    let slider = ScaleGame.slider(forRatio: pair.ratio)
    expect(abs(ScaleGame.ratio(forSlider: slider) - pair.ratio) < pair.ratio * 0.0001, "slider maths round-trips")
}

// MARK: - Borderline

do {
    resetDecks()
    let game = BorderlineGame()
    var total = 0
    for round in 0..<BorderlineGame.rounds {
        expect(!game.roundOver && game.guesses.isEmpty, "round \(round) starts clean")
        let wrong = Atlas.countries.first { $0.name != game.target.name }!
        game.guess(wrong)
        game.guess(wrong)
        expect(game.guesses.count == 1, "a repeated guess is ignored")
        expect(game.guesses[0].distanceKm > 0 && !game.guesses[0].isCorrect, "wrong guess gives a distance")
        expect(!game.suggestions(for: wrong.name).contains(wrong), "guessed countries leave the suggestions")
        let suggestion = game.suggestions(for: String(game.target.name.prefix(3)))
        expect(suggestion.contains(game.target), "typing the start of the name suggests it")
        game.guess(game.target)
        expect(game.solved && game.roundOver, "right guess ends the round")
        expect(game.lastPoints == Scoring.ladder(attempt: 2, maxAttempts: 6), "second-try points")
        total += game.lastPoints
        game.next()
    }
    expect(game.isFinished && game.score == total, "run ends with the summed score")
    game.restart()
    expect(!game.isFinished && game.score == 0 && game.roundIndex == 0, "restart clears the run")
    // Six wrong guesses lose the round.
    let others = Atlas.countries.filter { $0.name != game.target.name }.prefix(6)
    for country in others { game.guess(country) }
    expect(game.roundOver && !game.solved && game.lastPoints == 0, "six misses end the round with nothing")
}

// MARK: - Fourfold

do {
    resetDecks()
    let game = FourfoldGame()
    let puzzle = game.puzzle
    // A set with three from one group and one from another is "one away".
    var mixed = Array(puzzle.groups[0].words.prefix(3))
    mixed.append(puzzle.groups[1].words[0])
    mixed.forEach(game.toggle)
    game.submit()
    expect(game.mistakes == 1 && game.message == "One away", "one away is spotted")
    game.submit()
    expect(game.mistakes == 1, "the same wrong set is not charged twice")
    game.clearSelection()
    for group in puzzle.groups {
        group.words.forEach(game.toggle)
        expect(game.selected.count == 4, "four tiles selected")
        game.submit()
    }
    expect(game.isOver && game.board.isEmpty && game.foundByPlayer == 4, "all groups found")
    expect(game.score == 400 + 3 * 25, "score counts spare mistakes, got \(game.score)")
    game.finish()
    expect(game.isFinished, "finish ends the run")

    game.restart()
    let second = game.puzzle
    // Burn all four mistakes with different wrong sets.
    var attempts = 0
    outer: for a in 0..<4 {
        for b in 0..<4 {
            guard !game.isOver else { break outer }
            game.clearSelection()
            let pick = [second.groups[0].words[a], second.groups[1].words[b], second.groups[2].words[0], second.groups[3].words[0]]
            pick.forEach(game.toggle)
            game.submit()
            attempts += 1
        }
    }
    expect(game.isOver && game.mistakes == 4 && game.score == 0, "four mistakes end the puzzle")
    expect(game.solvedGroups.count == 4 && game.board.isEmpty, "the answer is revealed")
}

// MARK: - Ten Count

do {
    resetDecks()
    let game = TopTenGame()
    expect(game.submit("definitely not on any list") == .wrong, "wrong guess")
    expect(game.submit("Definitely NOT on any list") == .alreadyTried, "repeat wrong guess is free")
    expect(game.livesLeft == 4, "one life lost")
    for (index, entry) in game.list.entries.enumerated() {
        let outcome = game.submit(entry.spellings.last!)
        expect(outcome == .correct(rank: index + 1), "\(entry.name) accepted")
    }
    expect(game.isOver && game.score == 100, "full list scores 100")
    expect(game.submit(game.list.entries[0].name) == .ignored, "no guesses after the end")
    game.restart()
    expect(game.submit(game.list.entries[2].name) == .correct(rank: 3), "rank is reported")
    expect(game.submit(game.list.entries[2].name) == .alreadyFound, "duplicate is free")
    for number in 0..<5 { game.submit("wrong answer number \(number) xyz") }
    expect(game.isOver && game.score == 10, "five wrong guesses end it")
}

// MARK: - Critter Clues

do {
    resetDecks()
    var solvedCount = 0
    var worst = 0
    let rounds = 200
    for _ in 0..<rounds {
        let game = CritterGame()
        var candidates = Critters.all
        while !game.isOver {
            // A simple solver: guess any animal consistent with every clue so far.
            let guess = candidates[0]
            game.guess(guess)
            guard let row = game.rows.last else { break }
            candidates = candidates.filter { candidate in
                guard candidate.id != guess.id else { return false }
                let predicted = CritterGame.compare(guess, to: candidate, id: row.id)
                return predicted == row
            }
            if candidates.isEmpty { break }
        }
        if game.solved {
            solvedCount += 1
            worst = max(worst, game.rows.count)
            expect(game.score == Scoring.ladder(attempt: game.rows.count, maxAttempts: 8), "critter score")
        }
        expect(game.isOver, "critter game ends")
    }
    expect(solvedCount >= rounds * 9 / 10, "a clue-following solver nearly always wins (\(solvedCount) of \(rounds), worst \(worst) guesses)")
    let game = CritterGame()
    let row = CritterGame.compare(game.target, to: game.target, id: 0)
    expect([row.group, row.diet, row.home, row.legs, row.regions, row.weight].allSatisfy { $0 == .match }, "the answer matches itself")
    expect(game.suggestions(for: "").isEmpty && !game.suggestions(for: "li").isEmpty, "animal suggestions")
}

// MARK: - Price Point

do {
    resetDecks()
    let game = PriceGame()
    for _ in 0..<PriceGame.rounds {
        let price = game.item.price
        game.guess(price * 3)
        expect(game.guesses.last?.hint == .lower && game.guesses.last?.isClose == false, "too high says lower")
        game.guess(price * 0.8)
        expect(game.guesses.last?.hint == .higher && game.guesses.last?.isClose == true, "a bit low says higher and close")
        game.guess(-5)
        expect(game.guesses.count == 2, "nonsense amounts are ignored")
        game.guess(price * 1.04)
        expect(game.solved && game.lastPoints == Scoring.ladder(attempt: 3, maxAttempts: 6), "within five percent wins")
        game.next()
    }
    expect(game.isFinished && game.score == 3 * 67, "price run total, got \(game.score)")
}

// MARK: - Rare Find

do {
    resetDecks()
    let game = RareGame()
    let start = Date(timeIntervalSince1970: 1_000_000)
    game.tick(now: start)
    game.tick(now: start.addingTimeInterval(10))
    expect(abs(game.timeLeft - 15) < 0.01, "clock counts down, got \(game.timeLeft)")
    expect(game.submit("qqqqqq") == false && game.rejected.count == 1, "bad answer is rejected")
    expect(game.submit("QQQQQQ") == false && game.rejected.count == 1, "the same bad answer is listed once")
    let rare = game.prompt.answers.first { $0.tier == 5 }!
    expect(game.submit(rare.name), "rare answer accepted")
    expect(game.lastPoints == 100 && game.roundOver && game.score == 100, "rare answer scores 100")
    game.tick(now: start.addingTimeInterval(500))
    expect(game.roundOver && game.accepted != nil, "clock stops once answered")
    game.next()
    // Second prompt: let the clock run out.
    game.tick(now: start)
    game.tick(now: start.addingTimeInterval(26))
    expect(game.roundOver && game.accepted == nil && game.lastPoints == 0, "time out scores nothing")
    expect(game.submit(game.prompt.answers[0].name) == false, "no answers after time is up")
    game.next()
    for _ in 2..<RareGame.rounds {
        let common = game.prompt.answers.first { $0.tier == 1 }!
        expect(game.submit(common.name), "common answer accepted")
        expect(game.lastPoints == 10, "common answer scores 10")
        game.next()
    }
    expect(game.isFinished && game.score == 100 + 5 * 10, "rare run total, got \(game.score)")
}

// MARK: - Ballpark

do {
    resetDecks()
    let game = BallparkGame()
    game.lockIn(0)
    expect(!game.revealed, "zero is not a guess")
    game.lockIn(game.question.answer)
    expect(game.revealed && game.lastPoints == 100 && game.factor == 1, "exact answer")
    game.lockIn(1)
    expect(game.score == 100, "only one guess per question")
    game.next()
    game.lockIn(game.question.answer * 10)
    expect(game.lastPoints == 50 && abs(game.factor - 10) < 0.0001, "ten times off")
    game.next()
    game.lockIn(game.question.answer / 1000)
    expect(game.lastPoints == 0, "a thousand times off")
    game.next()
    expect(game.isFinished && game.score == 150, "ballpark total")
}

// MARK: - Trendline

do {
    resetDecks()
    let game = TrendGame()
    for round in 0..<TrendGame.rounds {
        let series = game.series
        expect(!game.canSubmit, "cannot submit an empty drawing")
        let real = Array(series.values.suffix(series.hiddenCount))
        for (index, value) in real.enumerated() {
            // Round 0 draws the real line, later rounds draw far too high.
            game.setValue(round == 0 ? value : series.axisMax * 10, at: index)
        }
        game.setValue(1, at: 99)
        expect(game.canSubmit, "a complete drawing can be submitted")
        game.submit()
        if round == 0 {
            expect(game.lastPoints == 100, "the real line scores 100")
        } else {
            expect(game.drawn.allSatisfy { $0 == series.axisMax }, "values are clamped to the chart")
            expect(game.lastPoints < 100, "a wild line scores less")
        }
        game.setValue(series.axisMin, at: 0)
        expect(game.drawn[0] != series.axisMin || series.axisMin == series.axisMax * 10, "no drawing after the reveal")
        game.next()
    }
    expect(game.isFinished, "trend run ends")
}

// MARK: - Scale It, Hue Recall, Pitch Match, Beat Keeper

do {
    resetDecks()
    let game = ScaleGame()
    for _ in 0..<ScaleGame.rounds {
        expect(abs(game.slider - ScaleGame.slider(forRatio: game.pair.ratio)) >= 0.1, "slider starts away from the answer")
        game.slider = ScaleGame.slider(forRatio: game.pair.ratio)
        game.lockIn()
        expect(game.lastPoints == 100, "exact size scores 100")
        game.next()
    }
    expect(game.isFinished && game.score == 500, "scale total")
    expect(ScaleGame.points(guess: 2, answer: 1) == 0 && ScaleGame.points(guess: 1.05, answer: 1) == 100, "scale scoring limits")
}

do {
    let red = HSB(hue: 0, saturation: 1, brightness: 1)
    expect(red.rgb.red == 1 && red.rgb.green == 0 && red.rgb.blue == 0, "pure red")
    let green = HSB(hue: 1.0 / 3, saturation: 1, brightness: 1).rgb
    expect(abs(green.green - 1) < 0.0001 && green.red < 0.0001, "pure green")
    let white = HSB(hue: 0.3, saturation: 0, brightness: 1)
    let black = HSB(hue: 0.9, saturation: 0.5, brightness: 0)
    expect(abs(white.distance(to: black) - 1) < 0.0001, "white to black is the largest distance")

    let game = HueGame()
    let start = Date(timeIntervalSince1970: 2_000_000)
    game.lockIn()
    expect(game.phase == .memorize, "cannot lock in while memorising")
    game.tick(now: start)
    game.tick(now: start.addingTimeInterval(1))
    expect(game.phase == .memorize && abs(game.timeLeft - 2) < 0.01, "colour countdown")
    game.tick(now: start.addingTimeInterval(3.1))
    expect(game.phase == .recreate, "colour hides after three seconds")
    game.guess = game.target
    game.lockIn()
    expect(game.phase == .revealed && game.lastPoints == 100, "the same colour scores 100")
    for _ in 1..<HueGame.rounds {
        game.next()
        game.tick(now: start)
        game.tick(now: start.addingTimeInterval(4))
        game.lockIn()
        expect(game.lastPoints >= 0 && game.lastPoints <= 100, "colour points in range")
    }
    game.next()
    expect(game.isFinished, "hue run ends")
}

do {
    let game = PitchGame()
    expect(abs(PitchGame.frequency(forSlider: 0) - 150) < 0.001 && abs(PitchGame.frequency(forSlider: 1) - 1200) < 0.001, "pitch slider range")
    expect(abs(PitchGame.semitones(between: 880, and: 440) - 12) < 0.0001, "an octave is twelve semitones")
    for _ in 0..<PitchGame.rounds {
        expect(game.targetHz >= 220 && game.targetHz <= 880, "target pitch in range")
        expect(game.useListen() && game.useListen() && game.useListen() && !game.useListen(), "three listens")
        game.slider = PitchGame.slider(forFrequency: game.targetHz)
        game.lockIn()
        expect(game.lastPoints == 100 && game.semitonesOff < 0.001, "matching pitch scores 100")
        game.next()
    }
    expect(game.isFinished && game.score == 500, "pitch total")
    expect(PitchGame.points(semitonesOff: 6) == 0 && PitchGame.points(semitonesOff: 0.2) == 100, "pitch scoring limits")
}

do {
    let game = BeatGame()
    for round in 0..<BeatGame.rounds {
        game.tap(at: 1)
        expect(game.taps.isEmpty, "taps before the beat are ignored")
        game.startListening()
        for _ in 0..<BeatGame.demoBeats { game.beatPlayed() }
        game.finishListening()
        expect(game.phase == .tapping && game.beatsPlayed == BeatGame.demoBeats, "listening leads to tapping")
        // Round 0 taps perfectly, the rest tap 10 percent slow.
        let step = game.interval * (round == 0 ? 1 : 1.1)
        for index in 0..<BeatGame.tapsNeeded {
            game.tap(at: 10 + Double(index) * step)
        }
        expect(game.phase == .revealed, "six taps finish the round")
        if round == 0 {
            expect(game.lastPoints == 100 && abs(game.tappedBPM - game.targetBPM) < 0.01, "perfect taps score 100")
        } else {
            expect(game.lastPoints > 40 && game.lastPoints < 80, "slow taps score partly, got \(game.lastPoints)")
        }
        game.next()
    }
    expect(game.isFinished, "beat run ends")
    expect(BeatGame.bpm(fromTaps: [0, 0.5, 1.0, 1.5]) == 120, "tempo from taps")
    expect(BeatGame.bpm(fromTaps: [3]) == 0, "one tap has no tempo")
}

resetDecks()
print("\(checks) checks, \(failures) failed")
exit(failures == 0 ? 0 : 1)
