//
//  Formatter.swift
//  Coco
//
//  Created by Marcelinus Gerardo on 17/08/25.
//

import Foundation

enum PriceFormatting {
    private static let idFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "id_ID")
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = true
        nf.groupingSeparator = "."
        nf.decimalSeparator = ","
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 0
        return nf
    }()

    static func formattedIndonesianDecimal(from raw: String) -> String {
        let normalized = raw.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return raw }
        return idFormatter.string(from: NSNumber(value: value)) ?? raw
    }
}
