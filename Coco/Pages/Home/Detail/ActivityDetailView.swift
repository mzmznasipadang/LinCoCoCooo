//
//  ActivityDetailView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

protocol ActivityDetailViewDelegate: AnyObject {
    func notifyPackagesDetailDidTap(with packageId: Int)
    func notifyHighlightsSeeMoreDidTap(fullText: String)
    func notifyPackageDetailsDidTap(with packageId: Int)
}

final class ActivityDetailView: UIView {
    weak var delegate: ActivityDetailViewDelegate?

    // MARK: - NEW: Scroll & Tabs
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var tabBarView: CustomTabBar?
    private var sectionTitles: [String] = []
    private var sectionAnchors: [UIView] = []
    private var isProgrammaticScroll = false
    private var stickyTabBar: CustomTabBar?
    private let tabSpacer = UIView()
    private var imageSliderHeight: NSLayoutConstraint?
    private var tabSpacerHeight: NSLayoutConstraint?
    var setNavigationTitle: ((String) -> Void)?
    var onStickyTabVisibilityChanged: ((Bool) -> Void)?
    private var lastStickyVisible: Bool = false
    private lazy var stickyBottomBar = createStickyBottomBar()
    private var bottomBarPriceLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let barHeight = stickyBottomBar.isHidden ? 0 : stickyBottomBar.frame.height
        scrollView.contentInset.bottom = barHeight
        scrollView.verticalScrollIndicatorInsets.bottom = barHeight
    }

    func configureView(_ data: ActivityDetailDataModel) {
        sectionTitles.removeAll()
        sectionAnchors.removeAll()
        tabBarView?.removeFromSuperview()
        // --- Title content ---
        titleLabel.text = data.title
        locationLabel.text = data.location
        
        // 1) Title Section
        contentStackView.addArrangedSubview(createTitleView())
        contentStackView.addArrangedSubview(createDivider())

        // 2) Highlights Section
        let highlightsDescription = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 2
        )
        let fullHighlights = data.tnc
        let highlightsView = createHighlightsSection(fullText: fullHighlights)

        sectionTitles.append("Highlights")
        let hlAnchor = makeAnchor()
        contentStackView.addArrangedSubview(hlAnchor)
        sectionAnchors.append(hlAnchor)
        contentStackView.addArrangedSubview(highlightsView)
        contentStackView.addArrangedSubview(createDivider())
        
        // 3) Package Section
        if !data.availablePackages.content.isEmpty {
            sectionTitles.append("Packages")
            let pkgAnchor = makeAnchor()
            contentStackView.addArrangedSubview(pkgAnchor)
            sectionAnchors.append(pkgAnchor)

            packageContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let sortedHosts = data.availablePackages.content.keys.sorted()

            for hostName in sortedHosts {
                guard let packagesForHost = data.availablePackages.content[hostName] else { continue }

                let hostLabel = UILabel(
                    font: .jakartaSans(forTextStyle: .body, weight: .semibold),
                    textColor: Token.additionalColorsBlack
                )
                hostLabel.text = hostName
                packageContainer.addArrangedSubview(hostLabel)

                for packageData in packagesForHost {
                    packageContainer.addArrangedSubview(
                        createPackageView(data: packageData)
                    )
                }

                if let lastViewInGroup = packageContainer.arrangedSubviews.last {
                    packageContainer.setCustomSpacing(24, after: lastViewInGroup)
                }
            }

            contentStackView.addArrangedSubview(packageSection)

            packageLabel.text = data.availablePackages.title
            packageLabel.isHidden = false

        } else {
            packageLabel.isHidden = true
        }
        
        contentStackView.addArrangedSubview(createDivider())

        // 4) Description Section
        let detailDescription = UILabel(
            font: .jakartaSans(forTextStyle: .body, weight: .regular),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        detailDescription.text = data.descriptionInfomation.content
        let detailView = createSectionView(
            title: data.descriptionInfomation.title,
            view: detailDescription
        )

        sectionTitles.append("Description")
        let detailAnchor = makeAnchor()
        contentStackView.addArrangedSubview(detailAnchor)
        sectionAnchors.append(detailAnchor)
        contentStackView.addArrangedSubview(detailView)

        contentStackView.addArrangedSubview(createDivider())

        scrollView.setContentOffset(.zero, animated: false)

        let tabs = CustomTabBar(titles: sectionTitles)
        tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tabs.delegate = self
        tabs.isHidden = true
        addSubview(tabs)
        NSLayoutConstraint.activate([
            tabs.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tabs.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabs.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabs.heightAnchor.constraint(equalToConstant: 48)
        ])
        self.stickyTabBar?.removeFromSuperview()
        self.stickyTabBar = tabs
        self.tabBarView = tabs

        tabs.setSelected(index: 0, animated: false, notify: false)
        layoutIfNeeded()
        scrollViewDidScroll(scrollView)
        setNavigationTitle?(data.title)
        
        if let priceText = data.lowestPriceFormatted {
            // Buat attributed string untuk harga
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.jakartaSans(forTextStyle: .title3, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
            let regularAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.jakartaSans(forTextStyle: .footnote, weight: .regular),
                .foregroundColor: Token.grayscale70
            ]

            let attributedPrice = NSMutableAttributedString(string: priceText, attributes: boldAttributes)
            attributedPrice.append(NSAttributedString(string: "/pax", attributes: regularAttributes))

            bottomBarPriceLabel?.attributedText = attributedPrice
            stickyBottomBar.isHidden = false
        } else {
            stickyBottomBar.isHidden = true
        }
    }

    func addImageSliderView(with view: UIView) {
        imageSliderView.subviews.forEach { $0.removeFromSuperview() }
        imageSliderView.addSubviewAndLayout(view)
    }

    func toggleImageSliderView(isShown: Bool) {
        imageSliderView.isHidden = !isShown
        imageSliderHeight?.constant = isShown ? 250 : 0
        setNeedsLayout()
        layoutIfNeeded()
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
        numberOfLines: 1
    )

    private lazy var packageSection = createPackageSection()
    lazy var packageLabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )

    lazy var packageContainer = createStackView(spacing: 18.0)
    private lazy var contentStackView = createStackView(spacing: 12)
    private lazy var headerStackView = createStackView(spacing: 0)

}

// MARK: - Setup
extension ActivityDetailView: UIScrollViewDelegate, CustomTabBarDelegate {
    func setupView() {
        scrollView.delegate = self

        scrollView.addSubviewAndLayout(contentView)
        contentView.layout { $0.widthAnchor(to: scrollView.widthAnchor) }

        addSubviewAndLayout(scrollView)
        backgroundColor = UIColor.from("#F5F5F5")
        scrollView.backgroundColor = .clear

        contentView.addSubviews([imageSliderView, contentStackView])

        imageSliderView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        imageSliderHeight = imageSliderView.heightAnchor.constraint(equalToConstant: 250)
        imageSliderHeight?.isActive = true

        contentStackView.layout {
            $0.top(to: imageSliderView.bottomAnchor, constant: 0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        contentStackView.layer.cornerRadius = 24.0
        contentStackView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner
        ]
        contentStackView.backgroundColor = Token.additionalColorsWhite

        imageSliderView.isHidden = true

        tabSpacer.translatesAutoresizingMaskIntoConstraints = false
        tabSpacerHeight = tabSpacer.heightAnchor.constraint(equalToConstant: 12)
        tabSpacerHeight?.isActive = true
        contentStackView.addArrangedSubview(tabSpacer)

        addSubview(stickyBottomBar)
        stickyBottomBar.layout {
            $0.leading(to: leadingAnchor)
            $0.trailing(to: trailingAnchor)
            $0.bottom(to: bottomAnchor)
        }

    }
    
    private func createStickyBottomBar() -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = .init(width: 0, height: -2)
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false

        let startFromLabel = UILabel()
        startFromLabel.text = "Start from"
        startFromLabel.font = .jakartaSans(forTextStyle: .caption1, weight: .regular)
        startFromLabel.textColor = .secondaryLabel

        let priceLabel = UILabel()
        self.bottomBarPriceLabel = priceLabel

        let seePackagesButton = UIButton(type: .system)
        seePackagesButton.setTitle("See Packages", for: .normal)
        seePackagesButton.titleLabel?.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        seePackagesButton.backgroundColor = Token.mainColorPrimary
        seePackagesButton.setTitleColor(.white, for: .normal)
        seePackagesButton.layer.cornerRadius = 14
        seePackagesButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        seePackagesButton.addTarget(self, action: #selector(seePackagesButtonTapped), for: .touchUpInside)

        let priceStack = createStackView(spacing: 2, axis: .vertical)
        priceStack.alignment = .leading
        priceStack.addArrangedSubview(startFromLabel)
        priceStack.addArrangedSubview(priceLabel)

        container.addSubviews([priceStack, seePackagesButton])

        priceStack.layout {
            $0.leading(to: container.leadingAnchor, constant: 16)
            $0.centerY(to: container.centerYAnchor)
            $0.top(to: container.topAnchor, constant: 12)
            $0.bottom(to: container.safeAreaLayoutGuide.bottomAnchor, constant: 4)
        }

        seePackagesButton.layout {
            $0.trailing(to: container.trailingAnchor, constant: -16)
            $0.centerY(to: container.centerYAnchor)
            $0.top(to: container.topAnchor, constant: 12)
            $0.bottom(to: container.safeAreaLayoutGuide.bottomAnchor, constant: 4)
        }

        container.isHidden = true
        return container
    }

    @objc private func seePackagesButtonTapped() {
        guard let packageSectionIndex = sectionTitles.firstIndex(of: "Packages") else { return }
        tabBarView?.setSelected(index: packageSectionIndex, animated: true, notify: false)
        scrollToSection(packageSectionIndex, animated: true)
    }

    private func makeAnchor() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.01).isActive = true
        return v
    }

    private func scrollToSection(_ index: Int, animated: Bool) {
        guard sectionAnchors.indices.contains(index) else { return }
        layoutIfNeeded()
        let anchor = sectionAnchors[index]
        let origin = anchor.convert(CGPoint.zero, to: scrollView)
        let y = max(0, origin.y - scrollView.adjustedContentInset.top)
        isProgrammaticScroll = true
        scrollView.setContentOffset(CGPoint(x: 0, y: y-50), animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isProgrammaticScroll = false
        }
    }

    // MARK: - CustomTabBarDelegate
    func customTabBar(_ tabBar: CustomTabBar, didSelect index: Int) {
        scrollToSection(index, animated: true)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let imageBottomInScroll = imageSliderView.convert(imageSliderView.bounds, to: scrollView).maxY
        let spacerY = tabSpacer.convert(CGPoint.zero, to: scrollView).y
        let viewportTop = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let stickThreshold = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let shouldStick = viewportTop >= imageBottomInScroll
        stickyTabBar?.isHidden = !shouldStick
        
        let targetSpacer: CGFloat = 0
        if tabSpacerHeight?.constant != targetSpacer {
            tabSpacerHeight?.constant = targetSpacer
            UIView.performWithoutAnimation { self.layoutIfNeeded() }
        }
        
        if shouldStick != lastStickyVisible {
            lastStickyVisible = shouldStick
            onStickyTabVisibilityChanged?(shouldStick)
        }

        guard !isProgrammaticScroll, !sectionAnchors.isEmpty else { return }

        var active = 0
        for i in sectionAnchors.indices {
            let y = sectionAnchors[i].convert(CGPoint.zero, to: scrollView).y
            let nextY =
                (i + 1 < sectionAnchors.count)
                ? sectionAnchors[i + 1].convert(CGPoint.zero, to: scrollView).y
                : .greatestFiniteMagnitude

            let halfway = y + (nextY - y) / 2.0
            if viewportTop < halfway {
                active = i
                break
            }
            if i == sectionAnchors.count - 1 {
                active = i
            }
        }

        if active != tabBarView?.selectedIndex {
            tabBarView?.setSelected(
                index: active,
                animated: true,
                notify: false
            )
        }
    }

}
