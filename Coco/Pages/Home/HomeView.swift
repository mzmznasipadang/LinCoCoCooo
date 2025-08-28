//
//  HomeView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class HomeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addErrorView(from view: UIView) {
        errorView.subviews.forEach { $0.removeFromSuperview() }
        errorView.addSubviewAndLayout(view)
    }
    
    func addSearchResultView(from view: UIView) {
        searchResultView.subviews.forEach { $0.removeFromSuperview() }
        searchResultView.addSubviewAndLayout(view)
    }
    
    func addLoadingView(from view: UIView) {
        loadingView.subviews.forEach { $0.removeFromSuperview() }
        loadingView.addSubviewAndLayout(view)
    }
    
    func toggleErrorView(isShown: Bool) {
        errorView.isHidden = !isShown
    }
    
    func toggleLoadingView(isShown: Bool) {
        loadingView.isHidden = !isShown
    }
    
    func addSearchBarView(from view: UIView) {
        searchBarView.subviews.forEach { $0.removeFromSuperview() }
        searchBarView.addSubviewAndLayout(view, insets: .init(vertical: 0, horizontal: 24.0))
    }
    
    private lazy var errorView: UIView = UIView()
    private lazy var contentStackView: UIStackView = createContentStackView()
    private lazy var searchBarView: UIView = UIView()
    private lazy var searchResultView: UIView = createSearchResultView()
    private lazy var loadingView: UIView = UIView()
    
    // Grouped Trip
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HomeActivityCell.self, forCellWithReuseIdentifier: "HomeActivityCell")
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "SectionHeader")
        return collectionView
    }()
}

private extension HomeView {
    func setupView() {
        addSubviewAndLayout(contentStackView)
        addSubviewAndLayout(loadingView)
        addSubviewAndLayout(errorView)
        
        errorView.isHidden = true
        loadingView.isHidden = true
    }
    
    func createContentStackView() -> UIStackView {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [
            searchBarView,
            searchResultView
        ])
        stackView.axis = .vertical
        stackView.spacing = 12.0
        return stackView
    }
    
    func createSearchResultView() -> UIView {
        let containerView = UIView()
        containerView.addSubview(collectionView)
        collectionView.layout {
            $0.top(to: containerView.topAnchor)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        return containerView
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(280)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(280),
                heightDimension: .estimated(280)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24)
            
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
}

// HeaderView for CollectionView
internal class SectionHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        label.textColor = Token.additionalColorsBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top(to: topAnchor, constant: 8)
                .leading(to: leadingAnchor)
                .trailing(to: trailingAnchor)
                .bottom(to: bottomAnchor, constant: -8)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
