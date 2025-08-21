//
//  TravelerDetailsCell.swift
//  Coco
//
//  Created by Victor Chandra on 21/08/25.
//

import Foundation
import UIKit

// MARK: - Traveler Details Cell
final class TravelerDetailsCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, phone: String, email: String) {
        nameTextField.text = name
        phoneTextField.text = phone
        emailTextField.text = email
    }
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var nameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var nameTextField: UITextField = createTextField(placeholder: "Type here...")
    
    private lazy var phoneLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var phoneTextField: UITextField = {
        let textField = createTextField(placeholder: "Type here...")
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private lazy var emailLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var emailTextField: UITextField = {
        let textField = createTextField(placeholder: "Type here...")
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        textField.textColor = Token.grayscale90
        textField.backgroundColor = Token.grayscale10
        textField.layer.cornerRadius = 12
        textField.placeholder = placeholder
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        return textField
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        nameLabel.text = "Name"
        phoneLabel.text = "Phone"
        emailLabel.text = "Email"
        
        contentView.addSubview(containerView)
        containerView.addSubviews([
            nameLabel,
            nameTextField,
            phoneLabel,
            phoneTextField,
            emailLabel,
            emailTextField
        ])
        
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 8)
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        nameLabel.layout {
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        nameTextField.layout {
            $0.top(to: nameLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        phoneLabel.layout {
            $0.top(to: nameTextField.bottomAnchor, constant: 20)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        phoneTextField.layout {
            $0.top(to: phoneLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        emailLabel.layout {
            $0.top(to: phoneTextField.bottomAnchor, constant: 20)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        emailTextField.layout {
            $0.top(to: emailLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.bottom(to: containerView.bottomAnchor, constant: -16)
            $0.height(48)
        }
    }
}

