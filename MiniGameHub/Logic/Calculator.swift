import Foundation

/// A pocket calculator for working out estimates in Ballpark. It behaves like
/// a simple desk calculator: each operator is applied as soon as the next one
/// (or equals) is pressed.
struct Calculator: Equatable {
    enum Operation: String, Equatable {
        case add = "+"
        case subtract = "-"
        case multiply = "x"
        case divide = "/"
    }

    enum Key: Equatable {
        case digit(Int)
        case point
        case operation(Operation)
        case equals
        case clear
        case backspace
    }

    /// What the screen shows.
    private(set) var display = "0"
    private var stored: Double?
    private var pending: Operation?
    /// True while the player is typing a number (as opposed to looking at a result).
    private var typing = false

    var value: Double {
        Double(display) ?? 0
    }

    var pendingSymbol: String? {
        pending?.rawValue
    }

    mutating func press(_ key: Key) {
        switch key {
        case .digit(let digit):
            guard (0...9).contains(digit) else { return }
            if !typing || display == "0" {
                display = String(digit)
            } else if display.count < 15 {
                display.append(String(digit))
            }
            typing = true

        case .point:
            if !typing {
                display = "0."
                typing = true
            } else if !display.contains(".") {
                display.append(".")
            }

        case .operation(let operation):
            if typing || stored == nil {
                apply()
            }
            pending = operation
            typing = false

        case .equals:
            apply()
            pending = nil
            stored = nil
            typing = false

        case .clear:
            self = Calculator()

        case .backspace:
            guard typing else { return }
            display.removeLast()
            if display.isEmpty || display == "-" {
                display = "0"
                typing = false
            }
        }
    }

    /// Folds the number on screen into the running total.
    private mutating func apply() {
        let current = value
        if let left = stored, let operation = pending {
            let result: Double
            switch operation {
            case .add: result = left + current
            case .subtract: result = left - current
            case .multiply: result = left * current
            case .divide: result = current == 0 ? .nan : left / current
            }
            stored = result
            display = Self.format(result)
        } else {
            stored = current
        }
    }

    static func format(_ number: Double) -> String {
        guard number.isFinite else { return "0" }
        if abs(number) >= 1e15 {
            return String(format: "%.6g", number)
        }
        if number == number.rounded() {
            return String(format: "%.0f", number)
        }
        var text = String(format: "%.6f", number)
        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }
        return text
    }
}
