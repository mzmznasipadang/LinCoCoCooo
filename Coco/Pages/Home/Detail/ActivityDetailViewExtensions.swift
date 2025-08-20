//
//  Activity.swift
//  Coco
//
//  Created by Lin Dan Christiano on 20/08/25.
//

import Foundation
import UIKit

// MARK: - UI Creation Methods
extension ActivityDetailView {
    
    func createChipLabel(text: String, backgroundColor: UIColor) -> UIView {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: .black,
            numberOfLines: 1
        )
        label.text = text
        
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 12
        containerView.addSubviewAndLayout(label, insets: .init(top: 6, left: 12, bottom: 6, right: 12))
        
        return containerView
    }
    
    func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = Token.grayscale30
        divider.layout {
            $0.height(1)
        }
        return divider
    }
    
    func createStackView(
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis
        return stackView
    }
    
    func createSectionView(title: String, view: UIView) -> UIView {
        let contentView = UIView()
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        titleLabel.text = title
        
        contentView.addSubviews([titleLabel, view])
        
        titleLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        view.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    func createIconTextView(image: UIImage, text: String) -> UIView {
        let imageView = UIImageView(image: image)
        imageView.layout {
            $0.size(20.0)
        }
        
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 2
        )
        label.text = text
        
        let containerView = UIView()
        containerView.addSubviews([imageView, label])
        
        imageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        label.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }
}
