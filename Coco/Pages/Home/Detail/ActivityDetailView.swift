//
//  ActivityDetailView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

protocol ActivityDetailViewDelegate: AnyObject {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool)
    func notifyPackagesDetailDidTap(with packageId: Int)
    func notifyHighlightsSeeMoreDidTap()
}

final class ActivityDetailView: UIView {
    weak var delegate: ActivityDetailViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: ActivityDetailDataModel) {
        titleLabel.text = data.title
        locationLabel.text = data.location
        
        // Title View Section
        contentStackView.addArrangedSubview(createTitleView())
        contentStackView.addArrangedSubview(createDivider())
        
        // Highlights section
        let highlightsDescription = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 2
        )
        highlightsDescription.text = "Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet"
        
        contentStackView.addArrangedSubview(createHighlightsSection(description: highlightsDescription))
        contentStackView.addArrangedSubview(createDivider())
        
        // Detail Information section
        let detailDescription = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 0
        )
        detailDescription.text = data.detailInfomation.content
        contentStackView.addArrangedSubview(createSectionView(title: data.detailInfomation.title, view: detailDescription))
        
        // Trip Provider Section
        contentStackView.addArrangedSubview(
            createSectionView(
                title: data.providerDetail.title,
                view: createProviderDetail(
                    imageUrl: data.providerDetail.content.imageUrlString,
                    name: data.providerDetail.content.name,
                    description: data.providerDetail.content.description
                )
            )
        )
        
        // Facilities Section
        if !data.tripFacilities.content.isEmpty {
            contentStackView.addArrangedSubview(
                createSectionView(
                    title: data.tripFacilities.title,
                    view: createBenefitListView(titles: data.tripFacilities.content)
                )
            )
        }
        
        // TnC Section
        if !data.tnc.isEmpty {
            let tncLabel = UILabel(
                font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
                textColor: Token.additionalColorsBlack,
                numberOfLines: 0
            )
            tncLabel.text = data.tnc
            contentStackView.addArrangedSubview(createSectionView(title: "Terms and Conditon", view: tncLabel))
        }
        
        // Package Section
        if !data.availablePackages.content.isEmpty {
            contentStackView.addArrangedSubview(packageSection)
            
            if data.availablePackages.content.count == data.hiddenPackages.count {
                packageButton.isHidden = true
                data.availablePackages.content.forEach { data in
                    packageContainer.addArrangedSubview(createPackageView(data: data))
                }
            } else {
                data.hiddenPackages.forEach { data in
                    packageContainer.addArrangedSubview(createPackageView(data: data))
                }
            }
            
            packageLabel.text = data.availablePackages.title
        }
        
        packageLabel.isHidden = data.availablePackages.content.isEmpty
    }
    
    func addImageSliderView(with view: UIView) {
        imageSliderView.subviews.forEach { $0.removeFromSuperview() }
        imageSliderView.addSubviewAndLayout(view)
    }
    
    func toggleImageSliderView(isShown: Bool) {
        imageSliderView.isHidden = !isShown
    }
    
    func updatePackageData(_ data: [ActivityDetailDataModel.Package]) {
        packageContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in data.enumerated() {
            let view = createPackageView(data: item)
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 8)
            packageContainer.addArrangedSubview(view)

            UIView.animate(
                withDuration: 0.3,
                delay: 0.05 * Double(index),
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }
    
    // MARK: - UI Components
    private lazy var imageSliderView = UIView()
    lazy var titleLabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    lazy var locationLabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    private lazy var packageSection = createPackageSection()
    lazy var packageLabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    lazy var packageButton = createPackageTextButton()
    
    lazy var packageContainer = createStackView(spacing: 18.0)
    private lazy var contentStackView = createStackView(spacing: 29.0)
    private lazy var headerStackView = createStackView(spacing: 0)
    
    lazy var isPackageButtonStateHidden = true
}

// MARK: - Setup
extension ActivityDetailView {
    func setupView() {
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        scrollView.addSubviewAndLayout(contentView)
        contentView.layout {
            $0.widthAnchor(to: scrollView.widthAnchor)
        }
        addSubviewAndLayout(scrollView)
        backgroundColor = UIColor.from("#F5F5F5")
        scrollView.backgroundColor = .clear

        contentView.addSubviews([imageSliderView, contentStackView])
        
        imageSliderView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .height(250)
        }
        
        contentStackView.layout {
            $0.top(to: imageSliderView.bottomAnchor, constant: 0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(top: 24, left: 16, bottom: 240, right: 16)
        contentStackView.layer.cornerRadius = 24.0
        contentStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentStackView.backgroundColor = Token.additionalColorsWhite
        
        imageSliderView.isHidden = true
    }
}
