import Foundation

struct BallparkQuestion: Equatable {
    let text: String
    let answer: Double
    let unit: String
}

/// Questions for Ballpark. Every answer is a well-established figure,
/// rounded the way reference books usually give it.
enum BallparkQuestions {
    static let all: [BallparkQuestion] = [
        BallparkQuestion(text: "How far is the Moon from the Earth, on average?", answer: 384_400, unit: "km"),
        BallparkQuestion(text: "How far is the Earth from the Sun, on average?", answer: 149_600_000, unit: "km"),
        BallparkQuestion(text: "How long is the Earth's equator?", answer: 40_075, unit: "km"),
        BallparkQuestion(text: "How wide is the Earth, measured through the centre?", answer: 12_742, unit: "km"),
        BallparkQuestion(text: "How wide is the Moon?", answer: 3_474, unit: "km"),
        BallparkQuestion(text: "How wide is the Sun?", answer: 1_392_000, unit: "km"),
        BallparkQuestion(text: "How wide is Jupiter?", answer: 139_820, unit: "km"),
        BallparkQuestion(text: "What is the surface area of the Earth?", answer: 510_000_000, unit: "square km"),
        BallparkQuestion(text: "How tall is Mount Everest?", answer: 8_849, unit: "metres"),
        BallparkQuestion(text: "How tall is Kilimanjaro?", answer: 5_895, unit: "metres"),
        BallparkQuestion(text: "How deep is the deepest point of the ocean?", answer: 10_935, unit: "metres"),
        BallparkQuestion(text: "How deep is Lake Baikal at its deepest?", answer: 1_642, unit: "metres"),
        BallparkQuestion(text: "How tall is Angel Falls, the world's highest waterfall?", answer: 979, unit: "metres"),
        BallparkQuestion(text: "How long is the Nile?", answer: 6_650, unit: "km"),
        BallparkQuestion(text: "How long is the Amazon River?", answer: 6_400, unit: "km"),
        BallparkQuestion(text: "How big is the Sahara Desert?", answer: 9_200_000, unit: "square km"),
        BallparkQuestion(text: "How big is Russia?", answer: 17_098_000, unit: "square km"),
        BallparkQuestion(text: "How big is Australia?", answer: 7_692_000, unit: "square km"),
        BallparkQuestion(text: "How far is it from London to New York in a straight line?", answer: 5_570, unit: "km"),
        BallparkQuestion(text: "How long is the Great Wall of China, counting every section?", answer: 21_196, unit: "km"),
        BallparkQuestion(text: "How long is the Panama Canal?", answer: 82, unit: "km"),
        BallparkQuestion(text: "How long is the Suez Canal?", answer: 193, unit: "km"),
        BallparkQuestion(text: "How tall is the Eiffel Tower, to the tip?", answer: 330, unit: "metres"),
        BallparkQuestion(text: "How many steps lead to the top of the Eiffel Tower?", answer: 1_665, unit: "steps"),
        BallparkQuestion(text: "How tall is the Burj Khalifa?", answer: 828, unit: "metres"),
        BallparkQuestion(text: "How tall is the Statue of Liberty, from the ground to the torch?", answer: 93, unit: "metres"),
        BallparkQuestion(text: "How long is the Golden Gate Bridge in total?", answer: 2_737, unit: "metres"),
        BallparkQuestion(text: "How long was the Titanic?", answer: 269, unit: "metres"),
        BallparkQuestion(text: "How high above the Earth does the International Space Station orbit?", answer: 400, unit: "km"),
        BallparkQuestion(text: "How fast does the International Space Station travel?", answer: 27_600, unit: "km per hour"),
        BallparkQuestion(text: "How fast does light travel?", answer: 299_792, unit: "km per second"),
        BallparkQuestion(text: "How fast does sound travel through air at room temperature?", answer: 343, unit: "metres per second"),
        BallparkQuestion(text: "How long is a light-year?", answer: 9_461_000_000_000, unit: "km"),
        BallparkQuestion(text: "How hot is the surface of the Sun?", answer: 5_500, unit: "degrees Celsius"),
        BallparkQuestion(text: "How old is the universe?", answer: 13_800_000_000, unit: "years"),
        BallparkQuestion(text: "How old is the Earth?", answer: 4_540_000_000, unit: "years"),
        BallparkQuestion(text: "How many Earth days does Mars take to orbit the Sun?", answer: 687, unit: "days"),
        BallparkQuestion(text: "How many Earth years does Neptune take to orbit the Sun?", answer: 165, unit: "years"),
        BallparkQuestion(text: "How many people were alive in late 2022?", answer: 8_000_000_000, unit: "people"),
        BallparkQuestion(text: "How many countries are members of the United Nations?", answer: 193, unit: "countries"),
        BallparkQuestion(text: "How many elements are in the periodic table?", answer: 118, unit: "elements"),
        BallparkQuestion(text: "How many bones does an adult human have?", answer: 206, unit: "bones"),
        BallparkQuestion(text: "How many bones are in one human hand, including the wrist?", answer: 27, unit: "bones"),
        BallparkQuestion(text: "How many nerve cells are in a human brain?", answer: 86_000_000_000, unit: "cells"),
        BallparkQuestion(text: "How many times does a human heart beat in a day?", answer: 100_000, unit: "beats"),
        BallparkQuestion(text: "How many seconds are in a year?", answer: 31_536_000, unit: "seconds"),
        BallparkQuestion(text: "How many hours are in a year?", answer: 8_760, unit: "hours"),
        BallparkQuestion(text: "How many minutes are in a week?", answer: 10_080, unit: "minutes"),
        BallparkQuestion(text: "How many metres long is a marathon?", answer: 42_195, unit: "metres"),
        BallparkQuestion(text: "How much water does an Olympic swimming pool hold?", answer: 2_500_000, unit: "litres"),
        BallparkQuestion(text: "How many keys does a standard piano have?", answer: 88, unit: "keys"),
        BallparkQuestion(text: "How high is a basketball hoop above the floor?", answer: 305, unit: "cm")
    ]
}
