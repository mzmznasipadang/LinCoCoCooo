//
//  UIKitTextField.swift
//  Coco
//
//  Created by AI on 20/08/25.
//

import Foundation
import UIKit

final class UIKitTextField: UIView {
    let textField = UITextField()

    init(placeholder: String, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)

        backgroundColor = Token.grayscale10
        layer.cornerRadius = 12

        textField.placeholder = placeholder
        textField.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        textField.textColor = Token.grayscale90
        textField.keyboardType = keyboardType

        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


