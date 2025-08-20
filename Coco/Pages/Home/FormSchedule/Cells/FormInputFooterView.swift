//
//  FormInputFooterView.swift
//  Coco
//
//  Created by AI on 20/08/25.
//

import Foundation
import UIKit

final class FormInputFooterView: UIView {
    // Expose fields if controller needs to read values later
    let timeButton = UIButton(type: .system)
    let paxField = UIKitTextField(placeholder: "Type here…", keyboardType: .numberPad)
    let nameField = UIKitTextField(placeholder: "Type here…")
    let phoneField = UIKitTextField(placeholder: "Type here…", keyboardType: .phonePad)
    let emailField = UIKitTextField(placeholder: "Type here…", keyboardType: .emailAddress)

    var onSelectTime: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        backgroundColor = .clear

        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 24

        // Select Time
        let timeStack = UIStackView()
        timeStack.axis = .vertical
        timeStack.spacing = 8
        let timeLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale70
        )
        timeLabel.text = "Select Time"

        let timeButtonContainer = UIView()
        timeButton.setTitle("7.30", for: .normal)
        timeButton.setTitleColor(Token.grayscale90, for: .normal)
        timeButton.contentHorizontalAlignment = .left
        timeButton.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        timeButtonContainer.layer.cornerRadius = 25
        timeButtonContainer.layer.borderWidth = 1
        timeButtonContainer.layer.borderColor = Token.mainColorPrimary.cgColor
        timeButtonContainer.backgroundColor = Token.additionalColorsWhite
        timeButtonContainer.addSubview(timeButton)
        timeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeButton.leadingAnchor.constraint(equalTo: timeButtonContainer.leadingAnchor, constant: 16),
            timeButton.trailingAnchor.constraint(equalTo: timeButtonContainer.trailingAnchor, constant: -16),
            timeButton.topAnchor.constraint(equalTo: timeButtonContainer.topAnchor, constant: 14),
            timeButton.bottomAnchor.constraint(equalTo: timeButtonContainer.bottomAnchor, constant: -14)
        ])
        timeButton.addTarget(self, action: #selector(handleSelectTime), for: .touchUpInside)

        timeStack.addArrangedSubview(timeLabel)
        timeStack.addArrangedSubview(timeButtonContainer)

        // Pax
        let paxStack = UIStackView()
        paxStack.axis = .vertical
        paxStack.spacing = 8
        let paxLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale70
        )
        paxLabel.text = "Number of participants"

        let paxFieldContainer = UIView()
        paxFieldContainer.addSubview(paxField)
        paxField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paxField.leadingAnchor.constraint(equalTo: paxFieldContainer.leadingAnchor),
            paxField.trailingAnchor.constraint(equalTo: paxFieldContainer.trailingAnchor),
            paxField.topAnchor.constraint(equalTo: paxFieldContainer.topAnchor),
            paxField.heightAnchor.constraint(equalToConstant: 52)
        ])
        let slotsLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
            textColor: Token.grayscale50
        )
        slotsLabel.text = "Available Slots: 10"
        let slotsRow = UIStackView(arrangedSubviews: [UIView(), slotsLabel])
        slotsRow.axis = .horizontal

        paxStack.addArrangedSubview(paxLabel)
        paxStack.addArrangedSubview(paxFieldContainer)
        paxStack.addArrangedSubview(slotsRow)

        // Traveler details
        let travelerLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
            textColor: Token.grayscale90
        )
        travelerLabel.text = "Traveler details"

        func labeled(_ title: String, field: UIView) -> UIStackView {
            let titleLabel = UILabel(
                font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
                textColor: Token.grayscale70
            )
            titleLabel.text = title
            let stack = UIStackView(arrangedSubviews: [titleLabel, field])
            stack.axis = .vertical
            stack.spacing = 8
            return stack
        }

        let travelerStack = UIStackView(arrangedSubviews: [
            travelerLabel,
            labeled("Name", field: nameField),
            labeled("Phone", field: phoneField),
            labeled("Email", field: emailField)
        ])
        travelerStack.axis = .vertical
        travelerStack.spacing = 20

        container.addArrangedSubview(timeStack)
        container.addArrangedSubview(paxStack)
        container.addArrangedSubview(travelerStack)
        addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 27),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -27),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    @objc private func handleSelectTime() {
        onSelectTime?()
    }
}


