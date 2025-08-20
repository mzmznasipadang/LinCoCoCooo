//
//  TermsCell.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

final class TermsCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: TermsDisplayItem) {
        titleLabel.text = item.title
        contentLabel.text = item.content
        
        // Handle bullet points
        if let bullets = item.bulletPoints, !bullets.isEmpty {
            let bulletText = bullets.map { "• \($0)" }.joined(separator: "\n")
            bulletPointsLabel.text = bulletText
            bulletPointsLabel.isHidden = false
        } else {
            bulletPointsLabel.isHidden = true
        }
        
        // Highlight important terms
        if item.isImportant {
            titleLabel.textColor = Token.alertsError
        } else {
            titleLabel.textColor = Token.grayscale90
        }
    }
    
    private lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .semibold),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    
    private lazy var contentLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale70,
        numberOfLines: 0
    )
    
    private lazy var bulletPointsLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale60,
        numberOfLines: 0
    )
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = Token.additionalColorsWhite
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            contentLabel,
            bulletPointsLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        contentView.addSubview(stackView)
        stackView.layout {
            $0.top(to: contentView.topAnchor, constant: 12)
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.bottom(to: contentView.bottomAnchor, constant: -12)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
        }
    }
}
