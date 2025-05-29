//
//  PhoneNumberFormatter.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 17.05.25.
//

import Foundation

enum PhoneNumberFormatter {
    private static let mask = "(XXX) XXX-XX-XX"

    static func digits(from text: String?) -> String {
        return text?.compactMap { $0.whateverDigit }.joined() ?? ""
    }

    static func applyMask(to text: String?) -> String {
        let digits = digits(from: text)
        guard !digits.isEmpty else { return "+7" }

        var result = "+7 "
        var index = digits.startIndex
        var maskIndex = mask.startIndex

        if digits.starts(with: "8") || digits.starts(with: "7") {
            index = digits.index(after: index)
        }

        var formattedText = ""
        while maskIndex < mask.endIndex && index < digits.endIndex {
            let maskChar = mask[maskIndex]
            if maskChar == "X" {
                formattedText.append(digits[index])
                index = digits.index(after: index)
            } else {
                formattedText.append(maskChar)
            }
            maskIndex = mask.index(after: maskIndex)
        }

        result += formattedText

        return result
    }

    static func isValid(_ text: String?) -> Bool {
        let digits = digits(from: text)
        return digits.count == 11 && digits.starts(with: "7")
    }
}

private extension String {
    var numberValue: String? {
        Int(self).map { String($0) }
    }
}

private extension Character {
    var whateverDigit: String? {
        if let number = String(self).numberValue {
            return String(number)
        }
        return nil
    }
}
