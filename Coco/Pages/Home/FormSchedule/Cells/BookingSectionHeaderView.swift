//
//  BookingSectionHeaderView.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

// MARK: - Booking Section Header View (Collapsible)
final class BookingSectionHeaderView: UITableViewHeaderFooterView {
    
    // A closure to handle the tap event, which will be implemented in the view controller.
    var tapHandler: (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, isExpanded: Bool) {
        titleLabel.text = title
        rotateChevron(isExpanded: isExpanded, animated: false) // Set initial state without animation
    }
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .bold),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = Token.grayscale50
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Setup
    
    private func setupView() {
        // Use a custom background view to set the color.
        let customBackgroundView = UIView()
        customBackgroundView.backgroundColor = Token.additionalColorsWhite
        self.backgroundView = customBackgroundView
        
        contentView.addSubviews([titleLabel, chevronImageView])
        
        titleLabel.layout {
            $0.leading(to: contentView.leadingAnchor, constant: 24)
            $0.centerY(to: contentView.centerYAnchor)
            $0.trailing(to: chevronImageView.leadingAnchor, constant: -8)
        }
        
        chevronImageView.layout {
            $0.trailing(to: contentView.trailingAnchor, constant: -24)
            $0.centerY(to: contentView.centerYAnchor)
            $0.size(20)
        }
        
        // Add tap gesture to the whole content view for easier interaction.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    /// Animates the chevron rotation when the section is expanded or collapsed.
    func rotateChevron(isExpanded: Bool, animated: Bool = true) {
        let rotationAngle = isExpanded ? CGFloat.pi : 0
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.chevronImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        } else {
            self.chevronImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    @objc private func handleTap() {
        // Execute the tap handler closure.
        tapHandler?()
    }
}
