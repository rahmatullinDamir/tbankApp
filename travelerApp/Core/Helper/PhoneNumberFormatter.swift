//
//  PhoneNumberFormatter.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 17.05.25.
//

import Foundation

enum PhoneNumber {
    static let mask = "(XXX) XXX-XX-XX"

    static func digits(from text: String?) -> String {
        return text?.compactMap { $0.whateverDigit }.joined() ?? ""
    }

    static func applyMask(to text: String?) -> String {
        let digits = digits(from: text)
        guard digits.count >= 10 else { return text ?? "" }

        var index = digits.startIndex
        let countryPrefix = "+7 "

        if digits.first == "8" && digits.count == 11 {
            index = digits.index(after: index)
        } else if digits.starts(with: "7") && digits.count > 1 {
            index = digits.index(after: index)
        } else if digits.count < 11 {
            return text ?? ""
        }

        var result = countryPrefix

        for char in mask {
            if index >= digits.endIndex {
                break
            }
            if char == "X" {
                result.append(digits[index])
                index = digits.index(after: index)
            } else {
                result.append(char)
            }
        }

        return result
    }

    static func isValid(_ text: String?) -> Bool {
        let digits = self.digits(from: text)

        if digits.count != 11 {
            return false
        }

        return digits.starts(with: "7") || digits.starts(with: "8")
    }
}

extension String {
    var numberValue: String? {
        Int(self).map { String($0) }
    }
}

extension Character {
    var whateverDigit: String? {
        if let number = String(self).numberValue {
            return String(number)
        }
        return nil
    }
}
