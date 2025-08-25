//
//  HomeActivityCellDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation

struct HomeActivityCellDataModel: Hashable {
    let id: Int
    
    let area: String
    let name: String
    let priceText: String
    let imageUrl: URL?
    
    init(id: Int, area: String, name: String, priceText: String, imageUrl: URL?) {
        self.id = id
        self.area = area
        self.name = name
        self.priceText = priceText
        self.imageUrl = imageUrl
    }
    
    init(activity: Activity) {
        self.id = activity.id
        self.area = activity.destination.name
        self.name = activity.title
        self.priceText = "\(activity.pricing)"
        self.imageUrl = if let thumbnail = activity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
            URL(string: thumbnail)
        }
        else {
            nil
        }
    }
    
    static func from(activity: AdditionalData) -> HomeActivityCellDataModel {
        let placeholderImageString = "https://placeholder.com/\(activity.id)"
        let priceValue = Double(activity.id) * 100000
        
        return HomeActivityCellDataModel(
            id: activity.id,
            area: activity.label,
            name: activity.title,
            priceText: "\(priceValue)",
            imageUrl: URL(string: placeholderImageString)
        )
    }
}

typealias HomeActivityCellSectionDataModel = (title: String?, dataModel: [HomeActivityCellDataModel])
