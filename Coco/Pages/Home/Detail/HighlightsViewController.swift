//
//  HighlightsViewController.swift
//  Coco
//
//  Created by Lin Dan Christiano on 19/08/25.
//

import UIKit

final class HighlightsViewController: UIViewController {
    
    private let fullContent: String
    private let facilities: [String]
    private let tnc: String

    init(content: String, tripFacilities: [String], tnc: String) {
        self.fullContent = content
        self.facilities = tripFacilities
        self.tnc = tnc
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
        let fullAttributedString = NSMutableAttributedString()
        
        // Style untuk judul (Facilities, Terms and Conditions)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.gray
        ]
        
        // Bagian Facilities
        if !facilities.isEmpty {
            let facilitiesTitle = NSAttributedString(string: "Facilities\n", attributes: titleAttributes)
            fullAttributedString.append(facilitiesTitle)
            
            let listParagraphStyle = NSMutableParagraphStyle()
            listParagraphStyle.lineSpacing = 4
            listParagraphStyle.paragraphSpacing = 8
            
            let listBodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: Token.additionalColorsBlack,
                .paragraphStyle: listParagraphStyle
            ]
            
            let facilitiesText = facilities.map { "• \($0)" }.joined(separator: "\n")
            fullAttributedString.append(NSAttributedString(string: facilitiesText + "\n", attributes: listBodyAttributes))
        }
        
        // Bagian Terms and Conditions
        if !tnc.isEmpty {
            let tncTitle = NSAttributedString(string: "\nTerms and Conditions\n", attributes: titleAttributes)
            fullAttributedString.append(tncTitle)
            
            let numberedTncText = parseNumberedParagraphs(from: tnc)
            
            let tncParagraphStyle = NSMutableParagraphStyle()
            tncParagraphStyle.lineSpacing = 4
            
            let tncBodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: Token.additionalColorsBlack,
                .paragraphStyle: tncParagraphStyle
            ]
            
            fullAttributedString.append(NSAttributedString(string: numberedTncText, attributes: tncBodyAttributes))
        }

        contentTextView.attributedText = fullAttributedString
    }
    
    private func parseNumberedParagraphs(from text: String) -> String {
        let paragraphs = text
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return paragraphs.enumerated().map { index, para in
            return "\(index + 1). \(para)"
        }.joined(separator: "\n\n")
    }
}
