//
//  ActivityDetailDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

struct ActivityDetailDataModel: Equatable {
    let title: String
    let location: String
    let imageUrlsString: [String]
    let durationMinutes: Int
    
    let detailInfomation: ActivitySectionLayout<String>
    let providerDetail: ActivitySectionLayout<ProviderDetail>
    let tripFacilities: ActivitySectionLayout<[String]>
    let tnc: String
    
    let availablePackages: ActivitySectionLayout<[Package]>
    let hiddenPackages: [Package]
    
    struct ProviderDetail: Equatable {
        let name: String
        let description: String
        let imageUrlString: String	
    }
    
    struct Package: Equatable {
        let imageUrlString: String
        let name: String
        let description: String
        let price: String
        let pricePerPerson: Double
        let minParticipants: Int
        let maxParticipants: Int
        
        let id: Int
        let minParticipants: Int
        let maxParticipants: Int
    }
    
    init(_ response: Activity) {
        title = response.title
        location = response.destination.name
        durationMinutes = response.durationMinutes
        imageUrlsString = response.images
            .filter { $0.imageType != .banner }
            .map { $0.imageUrl }
        
        detailInfomation = ActivitySectionLayout(
            title: "Details",
            content: response.description
        )
        
        let firstPackage = response.packages.first
        providerDetail = ActivitySectionLayout(
            title: "Trip Provider",
            content: ProviderDetail(
                name: firstPackage?.host?.name ?? "Host",
                description: firstPackage?.host?.bio ?? "",
                imageUrlString: firstPackage?.host?.profileImageUrl ?? ""
            )
        )
        tripFacilities = ActivitySectionLayout(
            title: "This Trip Includes",
            content: response.accessories.map { $0.name }
        )
        tnc = response.cancelable
        
        availablePackages = ActivitySectionLayout(
            title: "Available Packages",
            content: response.packages.map {
                Package(
                    imageUrlString: $0.imageUrl,
                    name: $0.name,
                    description: "Min.\($0.minParticipants) - Max.\($0.maxParticipants)",
                    price: "Rp\($0.pricePerPerson)",
                    id: $0.id,
                    minParticipants: $0.minParticipants,
                    maxParticipants: $0.maxParticipants
                )
            }
        )
        
        hiddenPackages = Array(availablePackages.content.prefix(2))
    }
}

struct ActivitySectionLayout<T: Equatable>: Equatable {
    let title: String
    let content: T
}
