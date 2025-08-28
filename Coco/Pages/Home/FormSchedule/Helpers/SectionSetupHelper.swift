//
//  SectionSetupHelper.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation
import UIKit

// MARK: - Section Setup Helper
internal class SectionSetupHelper {
    
    static func setupProviderSection(
        headerButton: UIButton,
        titleLabel: UILabel,
        chevronView: UIImageView,
        contentContainer: UIView
    ) {
        headerButton.addSubviews([titleLabel, chevronView])
        
        titleLabel.layout {
            $0.leading(to: headerButton.leadingAnchor, constant: 24)
            $0.centerY(to: headerButton.centerYAnchor)
        }
        
        chevronView.layout {
            $0.trailing(to: headerButton.trailingAnchor, constant: -24)
            $0.centerY(to: headerButton.centerYAnchor)
            $0.size(20)
        }
        
        headerButton.layout {
            $0.height(56)
        }
        
        // Provider content will be added dynamically
        contentContainer.isHidden = true
    }
    
    static func setupItinerarySection(
        headerButton: UIButton,
        titleLabel: UILabel,
        chevronView: UIImageView,
        contentContainer: UIView
    ) {
        headerButton.addSubviews([titleLabel, chevronView])
        
        titleLabel.layout {
            $0.leading(to: headerButton.leadingAnchor, constant: 24)
            $0.centerY(to: headerButton.centerYAnchor)
        }
        
        chevronView.layout {
            $0.trailing(to: headerButton.trailingAnchor, constant: -24)
            $0.centerY(to: headerButton.centerYAnchor)
            $0.size(20)
        }
        
        headerButton.layout {
            $0.height(56)
        }
        
        // Itinerary content will be added dynamically
        contentContainer.isHidden = true
    }
    
    static func createDashedSeparator() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // Create dashed line view that will be styled with CAShapeLayer
        let dashedLineView = DashedLineView()
        dashedLineView.dashColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1)
        dashedLineView.dashLength = 4
        dashedLineView.gapLength = 4
        
        container.addSubview(dashedLineView)
        dashedLineView.layout {
            $0.leading(to: container.leadingAnchor, constant: 24)
            $0.trailing(to: container.trailingAnchor, constant: -24)
            $0.centerY(to: container.centerYAnchor)
            $0.height(1)
        }
        
        container.layout {
            $0.height(1)
        }
        
        return container
    }
    
    static func rotateChevron(chevron: UIImageView, isExpanded: Bool) {
        let rotationAngle = isExpanded ? CGFloat.pi : 0
        UIView.animate(withDuration: 0.3) {
            chevron.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
}

// MARK: - Dashed Line Helper View
private class DashedLineView: UIView {
    var dashColor: UIColor = .lightGray
    var dashLength: CGFloat = 4
    var gapLength: CGFloat = 4
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDashedLine()
    }
    
    private func setupDashedLine() {
        layer.sublayers?.removeAll()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = dashColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [NSNumber(value: dashLength), NSNumber(value: gapLength)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
}
