//
//  TravelerDetailsCell.swift
//  Coco
//
//  Created by Claude on 22/08/25.
//

import Foundation
import UIKit

// MARK: - Traveler Data Model
struct TravelerData {
    let name: String
    let phone: String
    let email: String
    
    var isValid: Bool {
        return !name.isEmpty && isValidPhone(phone) && isValidEmail(email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

// MARK: - Traveler Details Cell Delegate
protocol TravelerDetailsCellDelegate: AnyObject {
    func travelerDetailsDidChange(_ data: TravelerData)
}

// MARK: - Traveler Details Cell
final class TravelerDetailsCell: UITableViewCell {
    
    weak var delegate: TravelerDetailsCellDelegate?
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
    
    private lazy var nameTextField: UITextField = createTextField(placeholder: Localization.Common.typeHere)
    
    private lazy var phoneLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var phoneTextField: UITextField = {
        let textField = createTextField(placeholder: Localization.Common.typeHere)
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private lazy var emailLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var emailTextField: UITextField = {
        let textField = createTextField(placeholder: Localization.Common.typeHere)
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    // Error labels
    private lazy var nameErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .regular)
        label.textColor = .systemRed
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    private lazy var phoneErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .regular)
        label.textColor = .systemRed
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .regular)
        label.textColor = .systemRed
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        textField.textColor = Token.grayscale90
        textField.backgroundColor = Token.grayscale10
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.placeholder = placeholder
        textField.returnKeyType = .done
        textField.delegate = self
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        // Add target for text changes
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        return textField
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        nameLabel.text = Localization.Form.TravelerDetails.name
        phoneLabel.text = Localization.Form.TravelerDetails.phone
        emailLabel.text = Localization.Form.TravelerDetails.email
        
        contentView.addSubview(containerView)
        containerView.addSubviews([
            nameLabel,
            nameTextField,
            nameErrorLabel,
            phoneLabel,
            phoneTextField,
            phoneErrorLabel,
            emailLabel,
            emailTextField,
            emailErrorLabel
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
        
        nameErrorLabel.layout {
            $0.top(to: nameTextField.bottomAnchor, constant: 4)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        phoneLabel.layout {
            $0.top(to: nameErrorLabel.bottomAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        phoneTextField.layout {
            $0.top(to: phoneLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        phoneErrorLabel.layout {
            $0.top(to: phoneTextField.bottomAnchor, constant: 4)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        emailLabel.layout {
            $0.top(to: phoneErrorLabel.bottomAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        emailTextField.layout {
            $0.top(to: emailLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        emailErrorLabel.layout {
            $0.top(to: emailTextField.bottomAnchor, constant: 4)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.bottom(to: containerView.bottomAnchor, constant: -16)
        }
    }
    
    // MARK: - Text Field Validation
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        notifyDataChange()
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        validateField(textField)
        notifyDataChange()
    }
    
    private func validateField(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        switch textField {
        case nameTextField:
            let isValid = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            updateFieldValidation(textField: nameTextField, errorLabel: nameErrorLabel, 
                                 isValid: isValid, errorMessage: Localization.Validation.Name.required)
            
        case phoneTextField:
            let isValid = isValidPhone(text)
            updateFieldValidation(textField: phoneTextField, errorLabel: phoneErrorLabel, 
                                 isValid: isValid, errorMessage: Localization.Validation.Phone.invalid)
            
        case emailTextField:
            let isValid = isValidEmail(text)
            updateFieldValidation(textField: emailTextField, errorLabel: emailErrorLabel, 
                                 isValid: isValid, errorMessage: Localization.Validation.Email.invalid)
        default:
            break
        }
    }
    
    private func updateFieldValidation(textField: UITextField, errorLabel: UILabel, isValid: Bool, errorMessage: String) {
        UIView.animate(withDuration: 0.2) {
            if !isValid && !(textField.text?.isEmpty ?? true) {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                errorLabel.text = errorMessage
                errorLabel.isHidden = false
                errorLabel.alpha = 1.0
            } else {
                textField.layer.borderColor = UIColor.clear.cgColor
                errorLabel.isHidden = true
                errorLabel.alpha = 0.0
            }
        }
        
        // Force layout update to ensure error label is visible
        self.contentView.layoutIfNeeded()
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func notifyDataChange() {
        let data = TravelerData(
            name: nameTextField.text ?? "",
            phone: phoneTextField.text ?? "",
            email: emailTextField.text ?? ""
        )
        delegate?.travelerDetailsDidChange(data)
    }
}

// MARK: - UITextFieldDelegate
extension TravelerDetailsCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move to next text field or dismiss keyboard
        switch textField {
        case nameTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}