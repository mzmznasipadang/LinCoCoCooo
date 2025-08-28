//
//  Font+ext.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import SwiftUI

extension Font {
    static func jakartaSans(
        forTextStyle style: UIFont.TextStyle,
        weight: UIFont.Weight = .regular,
        size: CGFloat? = nil
    ) -> Self {
        if let size = size {
            return .custom("JakartaSans-\(weight.fontNameSuffix)", size: size)
        } else {
            return UIFont.jakartaSans(forTextStyle: style, weight: weight).toFont()
        }
    }
}

private extension UIFont.Weight {
    var fontNameSuffix: String {
        switch self {
        case .semibold: return "SemiBold"
        case .bold: return "Bold"
        default: return "Regular"
        }
    }
}
