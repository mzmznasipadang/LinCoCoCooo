//
//  FormInputFooterView.swift
//  Coco
//
//  Created by AI on 20/08/25.
//

import Foundation
import UIKit

final class FormInputFooterView: UIView {
    // MARK: - Configuration
    struct Configuration {
        var availableSlotsText: String = "Available Slots: 10"
        var onSelectTime: (() -> Void)?
        var onSelectPax: (() -> Void)?
    }
    
    // MARK: - Properties
    private var configuration: Configuration
    private(set) var paxLabel: UILabel?
    private let contentStack = UIStackView()
    
    // MARK: - Public UI Elements
    let nameTextField = UITextField()
    let phoneTextField = UITextField()
    let emailTextField = UITextField()
    let paxTextField = UITextField()
    let timeValueLabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .regular),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    
    // MARK: - Initialization
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = Token.additionalColorsWhite
        
        let inset = UIStackView()
        inset.axis = .vertical
        inset.alignment = .fill
        inset.spacing = 24
        
        addSubview(inset)
        inset.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inset.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 27),
            inset.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -27),
            inset.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            inset.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
        
        inset.addArrangedSubview(makeSelectTimeSection())
        inset.addArrangedSubview(makePaxSection())
        inset.addArrangedSubview(makeTravelerDetailsSection())
    }
    
    // MARK: - Section Builders
    private func makeSelectTimeSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        
        let title = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        title.text = "Select Time"
        
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.backgroundColor = Token.additionalColorsWhite
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = Token.mainColorPrimary.cgColor
        
        let row = UIView()
        
        let label = timeValueLabel
        label.text = "7.30"
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = Token.grayscale50
        
        row.addSubviews([label, chevron])
        label.layout {
            $0.leading(to: row.leadingAnchor, constant: 16)
            $0.top(to: row.topAnchor, constant: 14)
            $0.bottom(to: row.bottomAnchor, constant: -14)
        }
        chevron.layout {
            $0.trailing(to: row.trailingAnchor, constant: -16)
            $0.centerY(to: label.centerYAnchor)
            $0.size(16)
        }
        
        button.addSubview(row)
        row.layout { $0.edges(to: button) }
        button.addTarget(self, action: #selector(didTapSelectTime), for: .touchUpInside)
        
        container.addArrangedSubview(title)
        container.addArrangedSubview(button)
        return container
    }
    
    private func makePaxSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        
        let title = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        title.text = "Number of participants"
        
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.backgroundColor = Token.additionalColorsWhite
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = Token.mainColorPrimary.cgColor
        
        let row = UIView()
        
        let paxLabel = UILabel(
            font: .jakartaSans(forTextStyle: .body, weight: .regular),
            textColor: Token.grayscale90,
            numberOfLines: 1
        )
        paxLabel.text = "1"
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = Token.grayscale50
        
        row.addSubviews([paxLabel, chevron])
        paxLabel.layout {
            $0.leading(to: row.leadingAnchor, constant: 16)
            $0.centerY(to: row.centerYAnchor)
        }
        chevron.layout {
            $0.trailing(to: row.trailingAnchor, constant: -16)
            $0.centerY(to: row.centerYAnchor)
            $0.size(16)
        }
        
        button.addSubview(row)
        row.layout {
            $0.edges(to: button)
            $0.height(50)
        }
        button.addTarget(self, action: #selector(didTapPaxSelector), for: .touchUpInside)
        
        self.paxLabel = paxLabel
        
        let hintRow = UIView()
        let spacer = UIView()
        let hint = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
            textColor: Token.grayscale50,
            numberOfLines: 1
        )
        hint.text = configuration.availableSlotsText
        
        hintRow.addSubviews([spacer, hint])
        spacer.layout {
            $0.leading(to: hintRow.leadingAnchor)
            $0.centerY(to: hintRow.centerYAnchor)
        }
        hint.layout {
            $0.leading(to: spacer.trailingAnchor)
            $0.trailing(to: hintRow.trailingAnchor)
            $0.centerY(to: hintRow.centerYAnchor)
        }
        
        container.addArrangedSubview(title)
        container.addArrangedSubview(button)
        container.addArrangedSubview(hintRow)
        return container
    }
    
    private func makeTravelerDetailsSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        
        let header = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
            textColor: Token.grayscale90,
            numberOfLines: 1
        )
        header.text = "Traveler details"
        
        container.addArrangedSubview(header)
        container.addArrangedSubview(labeledField(title: "Name", field: nameTextField, placeholder: "Type here…"))
        container.addArrangedSubview(labeledField(title: "Phone", field: phoneTextField, placeholder: "Type here…", keyboard: .phonePad))
        container.addArrangedSubview(labeledField(title: "Email", field: emailTextField, placeholder: "Type here…", keyboard: .emailAddress))
        return container
    }
    
    private func labeledField(title: String, field: UITextField, placeholder: String, keyboard: UIKeyboardType = .default) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        titleLabel.text = title
        
        field.placeholder = placeholder
        field.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        field.textColor = Token.grayscale90
        field.keyboardType = keyboard
        field.backgroundColor = Token.grayscale10
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(field)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        return container
    }
    
    // MARK: - Actions
    @objc private func didTapSelectTime() {
        configuration.onSelectTime?()
    }
    
    @objc private func didTapPaxSelector() {
        configuration.onSelectPax?()
    }
}
