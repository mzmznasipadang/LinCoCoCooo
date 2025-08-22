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
    
    let descriptionInfomation: ActivitySectionLayout<String>
    let providerDetail: ActivitySectionLayout<ProviderDetail>
    let tripFacilities: ActivitySectionLayout<[String]>
    let tnc: String
    
    let availablePackages: ActivitySectionLayout<[String: [Package]]>
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
        let id: Int
        let minParticipants: Int
        let maxParticipants: Int
        let hostName: String
    }
    
    init(_ response: Activity) {
        title = response.title
        location = response.destination.name
        imageUrlsString = response.images
            .filter { $0.imageType != .banner }
            .map { $0.imageUrl }
        
        descriptionInfomation = ActivitySectionLayout(
            title: "Description",
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
            title: "Facilities",
            content: response.accessories.map { $0.name }
        )
        tnc = response.cancelable
        
        let allPackages = response.packages.map {
            Package(
                imageUrlString: $0.imageUrl,
                name: $0.name,
                description: "\($0.minParticipants) - \($0.maxParticipants) pax", // Format teks diubah
                price: "Rp\($0.pricePerPerson.formatted(.number.locale(Locale(identifier: "id_ID"))))/pax", // Format harga diubah
                id: $0.id,
                minParticipants: $0.minParticipants,
                maxParticipants: $0.maxParticipants,
                hostName: $0.host?.name ?? "Unknown Host" // <-- Isi properti baru
            )
        }

        let groupedPackages = Dictionary(grouping: allPackages, by: { $0.hostName })

        availablePackages = ActivitySectionLayout(
            title: "Available Packages",
            content: groupedPackages
        )
        
        hiddenPackages = Array(allPackages.prefix(2))
    }
}

struct ActivitySectionLayout<T: Equatable>: Equatable {
    let title: String
    let content: T
}
