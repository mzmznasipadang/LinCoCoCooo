//
//  HomeCollectionContent.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

enum HomeCollectionItem: Hashable, Sendable {
    case activity(HomeActivityCellDataModel)
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .activity(let model):
            hasher.combine("activity")
            hasher.combine(model)
        }
    }
    
    static func == (lhs: HomeCollectionItem, rhs: HomeCollectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.activity(let lhsModel), .activity(let rhsModel)):
            return lhsModel == rhsModel
        }
    }
}

typealias HomeCollectionViewDataSource = UICollectionViewDiffableDataSource<HomeCollectionContent.Section, HomeCollectionItem>
typealias HomeCollectionViewSnapShot = NSDiffableDataSourceSnapshot<HomeCollectionContent.Section, HomeCollectionItem>

struct HomeCollectionContent {
    let section: Section
    let items: [HomeActivityCellDataModel]
    
    enum SectionType: Hashable, Sendable {
        case activity
    }
    
    struct Section: Hashable, Sendable {
        let type: SectionType
        let title: String?
    }
}
