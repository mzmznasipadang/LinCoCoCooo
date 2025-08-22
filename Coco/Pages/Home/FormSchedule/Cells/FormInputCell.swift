//
//  FormInputCell.swift
//  Coco
//
//  Created by Claude on 22/08/25.
//

import Foundation
import UIKit

// MARK: - Form Input Cell
final class FormInputCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onSelectTime: (() -> Void)?
    var onSelectPax: (() -> Void)?
    
    func configure(selectedTime: String, participantCount: String) {
        timeButton.setTitle(selectedTime.isEmpty ? "7.30" : selectedTime, for: .normal)
        paxTextField.text = participantCount.isEmpty ? "1" : participantCount
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
    
    private lazy var selectTimeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
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
        
        // Add chevron
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
    
    private lazy var participantsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    
    private lazy var paxTextField: UITextField = {
        let textField = UITextField()
        textField.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        textField.textColor = Token.grayscale90
        textField.backgroundColor = Token.grayscale10
        textField.layer.cornerRadius = 12
        textField.keyboardType = .numberPad
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private lazy var availableSlotsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
        textColor: Token.grayscale50,
        numberOfLines: 1
    )
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        selectTimeLabel.text = "Select Time"
        participantsLabel.text = "Number of participants"
        availableSlotsLabel.text = "Available Slots: 10"
        availableSlotsLabel.textAlignment = .right
        
        contentView.addSubview(containerView)
        containerView.addSubviews([
            selectTimeLabel,
            timeButton,
            participantsLabel,
            paxTextField,
            availableSlotsLabel
        ])
        
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
    
    @objc private func timeButtonTapped() {
        onSelectTime?()
    }
}