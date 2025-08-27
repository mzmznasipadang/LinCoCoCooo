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
    ///   - availableSlots: The number of available slots (optional)
    func configure(selectedTime: String, participantCount: String, availableSlots: Int? = nil) {
        timeButton.setTitle(selectedTime.isEmpty ? Localization.Common.selectDate : selectedTime, for: .normal)
        paxTextField.text = participantCount.isEmpty ? "Select Number of Participants" : participantCount
        
        print("🔍 FormInputCell configure - SelectedTime: \(selectedTime), ParticipantCount: \(participantCount), AvailableSlots: \(availableSlots ?? -999)")
        print("🔍 FormInputCell - paxTextField.text after setting: '\(paxTextField.text ?? "nil")'")
        
        // Force the text field to refresh its display
        paxTextField.setNeedsDisplay()
        paxTextField.layoutIfNeeded()
        
        // Update available slots text
        if let slots = availableSlots {
            let slotsText = Localization.Form.availableSlots(slots)
            availableSlotsLabel.text = slotsText
            availableSlotsLabel.textColor = slots > 0 ? Token.grayscale50 : Token.alertsError
            print("✅ Updated available slots label: \(slotsText), Color: \(slots > 0 ? "Normal" : "Red")")
        } else {
            let defaultSlotsText = Localization.Form.availableSlots(10)
            availableSlotsLabel.text = defaultSlotsText
            availableSlotsLabel.textColor = Token.grayscale50
            print("⚠️ Using default slots: \(defaultSlotsText)")
        }
    }
    
    // MARK: - UI Components
    
    /// Container view with white background
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        return view
    }()
    
    /// Label for the date selection section
    private lazy var selectTimeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    /// Button for date/time selection with calendar popup
    /// Styled as input field with calendar icon
    private lazy var timeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 1)
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1).cgColor
        button.setTitleColor(UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1), for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        // Add calendar icon to match Figma design
        let calendar = UIImageView(image: UIImage(systemName: "calendar"))
        calendar.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        button.addSubview(calendar)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendar.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            calendar.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            calendar.widthAnchor.constraint(equalToConstant: 20),
            calendar.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Label for the participant count section
    private lazy var participantsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    /// Text field for participant count with custom tap handling and chevron
    /// Styled to match Figma design with white background and blue border
    private lazy var paxTextField: UITextField = {
        let textField = UITextField()
        textField.font = .jakartaSans(forTextStyle: .body, weight: .medium)
        textField.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        textField.backgroundColor = UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 1)
        textField.layer.cornerRadius = 24
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1).cgColor
        textField.keyboardType = .numberPad
        
        // Make it behave like a button for selection while preventing keyboard
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        
        // Add tap gesture for custom selection behavior
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(paxFieldTapped))
        textField.addGestureRecognizer(tapGesture)
        
        // Prevent keyboard from showing by providing empty input view
        textField.inputView = UIView()
        
        // Add padding for better visual appearance - leave space for chevron on the right
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Set text insets to account for chevron space
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 0))
        textField.rightViewMode = .always
        
        return textField
    }()
    
    /// Chevron icon for participant field dropdown indication
    private lazy var paxChevronView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Label showing available slots information
    private lazy var availableSlotsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    // MARK: - Setup
    
    /// Sets up the cell's view hierarchy and layout constraints
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Configure labels with default text
        selectTimeLabel.text = "Select Date"
        participantsLabel.text = "Number of participants"
        availableSlotsLabel.text = "Available Slots: 4"
        availableSlotsLabel.textAlignment = .right
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubviews([
            selectTimeLabel,
            timeButton,
            participantsLabel,
            paxTextField,
            paxChevronView,
            availableSlotsLabel
        ])
        
        // Layout constraints using custom layout helper
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 0)
            $0.leading(to: contentView.leadingAnchor, constant: 0)
            $0.trailing(to: contentView.trailingAnchor, constant: 0)
            $0.bottom(to: contentView.bottomAnchor, constant: 0)
        }
        
        selectTimeLabel.layout {
            $0.top(to: containerView.topAnchor, constant: 24)
            $0.leading(to: containerView.leadingAnchor, constant: 24)
            $0.trailing(to: containerView.trailingAnchor, constant: -24)
        }
        
        timeButton.layout {
            $0.top(to: selectTimeLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 24)
            $0.trailing(to: containerView.trailingAnchor, constant: -24)
            $0.height(52)
        }
        
        participantsLabel.layout {
            $0.top(to: timeButton.bottomAnchor, constant: 24)
            $0.leading(to: containerView.leadingAnchor, constant: 24)
            $0.trailing(to: containerView.trailingAnchor, constant: -24)
        }
        
        paxTextField.layout {
            $0.top(to: participantsLabel.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 24)
            $0.trailing(to: containerView.trailingAnchor, constant: -24)
            $0.height(52)
        }
        
        paxChevronView.layout {
            $0.centerY(to: paxTextField.centerYAnchor)
            $0.trailing(to: paxTextField.trailingAnchor, constant: -16)
            $0.width(20)
            $0.height(20)
        }
        
        availableSlotsLabel.layout {
            $0.top(to: paxTextField.bottomAnchor, constant: 8)
            $0.trailing(to: containerView.trailingAnchor, constant: -24)
            $0.bottom(to: containerView.bottomAnchor, constant: -24)
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
