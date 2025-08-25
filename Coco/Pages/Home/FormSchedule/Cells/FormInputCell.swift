//
//  FormInputCell.swift
//  Coco
//
//  Created by Claude on 22/08/25.
//

import Foundation
import UIKit

// MARK: - Form Input Cell

/// Table view cell for the form input section of the booking detail screen
/// Contains date selection and participant count input fields
/// Implements custom tap handling for validation-based participant selection
final class FormInputCell: UITableViewCell {
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Callbacks
    
    /// Callback triggered when the time/date selection button is tapped
    var onSelectTime: (() -> Void)?
    
    /// Callback triggered when the participant count field is tapped
    var onSelectPax: (() -> Void)?
    
    // MARK: - Configuration
    
    /// Configures the cell with current form data
    /// - Parameters:
    ///   - selectedTime: The selected date string or "Select Date" placeholder
    ///   - participantCount: The current participant count as string
    func configure(selectedTime: String, participantCount: String) {
        timeButton.setTitle(selectedTime.isEmpty ? Localization.Common.selectDate : selectedTime, for: .normal)
        paxTextField.text = participantCount.isEmpty ? "1" : participantCount
    }
    
    // MARK: - UI Components
    
    /// Container view with shadow and rounded corners
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
    
    /// Label for the date selection section
    private lazy var selectTimeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    /// Button for date/time selection with calendar popup
    /// Styled as input field with chevron icon
    private lazy var timeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Token.additionalColorsWhite
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = Token.mainColorPrimary.cgColor
        button.setTitleColor(Token.grayscale90, for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        // Add chevron icon to indicate dropdown behavior
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.tintColor = Token.grayscale50
        button.addSubview(chevron)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Label for the participant count section
    private lazy var participantsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    /// Text field for participant count with custom tap handling
    /// Configured to show selection popup instead of keyboard
    private lazy var paxTextField: UITextField = {
        let textField = UITextField()
        textField.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        textField.textColor = Token.grayscale90
        textField.backgroundColor = Token.grayscale10
        textField.layer.cornerRadius = 12
        textField.keyboardType = .numberPad
        
        // Make it behave like a button for selection while preventing keyboard
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        
        // Add tap gesture for custom selection behavior
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(paxFieldTapped))
        textField.addGestureRecognizer(tapGesture)
        
        // Prevent keyboard from showing by providing empty input view
        textField.inputView = UIView()
        
        // Add padding for better visual appearance
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    /// Label showing available slots information
    private lazy var availableSlotsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
        textColor: Token.grayscale50,
        numberOfLines: 1
    )
    
    // MARK: - Setup
    
    /// Sets up the cell's view hierarchy and layout constraints
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Configure labels with default text
        selectTimeLabel.text = "Select Dates"
        participantsLabel.text = "Number of participants"
        availableSlotsLabel.text = "Available Slots: 10"
        availableSlotsLabel.textAlignment = .right
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubviews([
            selectTimeLabel,
            timeButton,
            participantsLabel,
            paxTextField,
            availableSlotsLabel
        ])
        
        // Layout constraints using custom layout helper
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 8)
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        selectTimeLabel.layout {
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        timeButton.layout {
            $0.top(to: selectTimeLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        participantsLabel.layout {
            $0.top(to: timeButton.bottomAnchor, constant: 24)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        paxTextField.layout {
            $0.top(to: participantsLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(48)
        }
        
        availableSlotsLabel.layout {
            $0.top(to: paxTextField.bottomAnchor, constant: 8)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.bottom(to: containerView.bottomAnchor, constant: -16)
        }
    }
    
    // MARK: - Actions
    
    /// Handles time/date button tap to show calendar selection
    @objc private func timeButtonTapped() {
        onSelectTime?()
    }
    
    /// Handles participant field tap to show validation-based selection
    @objc private func paxFieldTapped() {
        onSelectPax?()
    }
}