//
//  MyTripListCardView.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation
import UIKit
import SwiftUI

protocol MyTripListCardViewDelegate: AnyObject {
    func notifyTripListCardDidTap(at index: Int)
}

final class MyTripListCardView: UIView {
    weak var delegate: MyTripListCardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(dataModel: MyTripListCardDataModel, index: Int) {
        self.index = index
        statusLabelView.updateTitle(dataModel.statusLabel.text)
        statusLabelView.updateStyle(dataModel.statusLabel.style)
        dateLabel.text = dataModel.dateText
        tripLabel.text = dataModel.title
        locationLabel.text = dataModel.location
        imageView.loadImage(from: URL(string: dataModel.imageUrl))
        
        // Custom text label with NSAttributedString
        let packageRegularFont = UIFont.jakartaSans(forTextStyle: .footnote, weight: .regular)
        let packageBoldFont = UIFont.jakartaSans(forTextStyle: .footnote, weight: .semibold)
        
        let packageAttributedString = NSMutableAttributedString(
            string: "Package: ",
            attributes: [.font: packageRegularFont, .foregroundColor: Token.grayscale90]
        )
        packageAttributedString.append(NSAttributedString(
            string: dataModel.packageType,
            attributes: [.font: packageBoldFont, .foregroundColor: Token.grayscale90]
        ))
        packageTypeLabel.attributedText = packageAttributedString
        
        let paxBoldFont = UIFont.jakartaSans(forTextStyle: .footnote, weight: .semibold)
        let paxRegularFont = UIFont.jakartaSans(forTextStyle: .footnote, weight: .regular)
        
        let paxAttributedString = NSMutableAttributedString(
            string: "\(dataModel.totalPax)",
            attributes: [.font: paxBoldFont, .foregroundColor: Token.grayscale90]
        )
        paxAttributedString.append(NSAttributedString(
            string: " Person",
            attributes: [.font: paxRegularFont, .foregroundColor: Token.grayscale90]
        ))
        totalPaxLabel.attributedText = paxAttributedString
    }
    
    private lazy var imageView: UIImageView = createImageView()
    private lazy var statusLabelView: CocoStatusLabelHostingController = CocoStatusLabelHostingController(
        title: "",
        style: .pending
    )
    private lazy var dateLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    private lazy var tripLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    private lazy var packageTypeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    private lazy var totalPaxLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .semibold),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    
    private var index: Int = 0
}

private extension MyTripListCardView {
    func setupView() {
        // Top container for Status and Date
        let topContainer = UIView()
        topContainer.addSubviews([statusLabelView.view, dateLabel])
        
        statusLabelView.view.layout {
            $0.leading(to: topContainer.leadingAnchor)
                .top(to: topContainer.topAnchor)
                .bottom(to: topContainer.bottomAnchor)
        }
        
        dateLabel.layout {
            $0.trailing(to: topContainer.trailingAnchor)
                .centerY(to: statusLabelView.view.centerYAnchor)
        }
        
        // Location content view
        let locationContentView = UIView()
        let locationIconImageView = UIImageView(image: CocoIcon.icPinPointBlue.getImageWithTintColor(Token.grayscale90))
        locationIconImageView.contentMode = .scaleAspectFit
        locationIconImageView.layout {
            $0.size(12)
        }
        locationContentView.addSubviews([locationIconImageView, locationLabel])
        
        locationIconImageView.layout {
            $0.leading(to: locationContentView.leadingAnchor)
                .top(to: locationContentView.topAnchor)
                .bottom(to: locationContentView.bottomAnchor)
        }
        
        locationLabel.layout {
            $0.leading(to: locationIconImageView.trailingAnchor, constant: 4.0)
                .centerY(to: locationIconImageView.centerYAnchor)
                .trailing(to: locationContentView.trailingAnchor)
        }
        
        // Right side vertical stack
        let rightSideStackView = UIStackView(arrangedSubviews: [
            tripLabel,
            locationContentView
        ])
        rightSideStackView.axis = .vertical
        rightSideStackView.spacing = 4.0
        rightSideStackView.alignment = .leading
        
        // Main content container
        let mainContentContainer = UIView()
        mainContentContainer.addSubviews([imageView, rightSideStackView])
        
        imageView.layout {
            $0.leading(to: mainContentContainer.leadingAnchor)
                .top(to: mainContentContainer.topAnchor)
                .bottom(to: mainContentContainer.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        rightSideStackView.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 16.0)
                .top(to: mainContentContainer.topAnchor)
                .trailing(to: mainContentContainer.trailingAnchor)
                .bottom(to: mainContentContainer.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        // Bottom info stack
        let bottomInfoStackView = UIStackView(arrangedSubviews: [
            packageTypeLabel,
            totalPaxLabel
        ])
        bottomInfoStackView.axis = .vertical
        bottomInfoStackView.spacing = 4.0
        bottomInfoStackView.alignment = .leading
        
        // Main vertical stack
        let mainStackView = UIStackView(arrangedSubviews: [
            topContainer,
            mainContentContainer,
            bottomInfoStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 12.0
        
        addSubviewAndLayout(mainStackView, insets: UIEdgeInsets(edges: 16.0))
        
        backgroundColor = Token.additionalColorsWhite
        layer.cornerRadius = 16.0
        layer.borderWidth = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4.0
        clipsToBounds = false
    }
    
    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14.0
        imageView.layout {
            $0.width(100)
                .height(100)
        }
        return imageView
    }
    
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func cardTapped() {
        delegate?.notifyTripListCardDidTap(at: index)
    }
}
