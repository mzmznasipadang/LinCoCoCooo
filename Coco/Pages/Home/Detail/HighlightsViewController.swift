//
//  HighlightsViewController.swift
//  Coco
//
//  Created by Lin Dan Christiano on 19/08/25.
//

import UIKit

class HighlightsViewController: UIViewController {

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Highlights"
        label.textAlignment = .center
        return label
    }()

    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        return textView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(handleView)
        view.addSubview(titleLabel)
        view.addSubview(contentTextView)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Content Configuration
    private func configureContent() {
        let fullMessage = """
        Activities:
        • Snorkeling in crystal clear waters
        • Underwater photography sessions
        • Marine life observation
        • Coral reef exploration
        
        Facilities:
        • Professional snorkeling equipment
        • Life jackets and safety gear
        • Underwater cameras available
        • Experienced dive guides
        • First aid equipment on board
        
        Terms and Conditions:
        • Minimum age requirement: 8 years old
        • Swimming ability required
        • Weather dependent activity
        • Cancellation policy: 24 hours notice
        • Health restrictions may apply
        """
        
        // Atur styling untuk bullets
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]
        
        contentTextView.attributedText = NSAttributedString(string: fullMessage, attributes: attributes)
    }
}
