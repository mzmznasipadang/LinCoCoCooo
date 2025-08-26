//
//  ActivityDetailDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

struct ActivityDetailDataModel: Equatable {
    let id: Int
    let label: String?
    let title: String
    let location: String
    let imageUrlsString: [String]
    let durationMinutes: Int
    
    let descriptionInfomation: ActivitySectionLayout<String>
    let providerDetail: ActivitySectionLayout<ProviderDetail>
    let tripFacilities: ActivitySectionLayout<[String]>
    let tnc: String
    
    let lowestPriceFormatted: String?
    
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
        let pricePerPerson: Double
        let minParticipants: Int
        let maxParticipants: Int
        let id: Int
        let hostName: String
    }
    
    init(_ response: Activity) {
        id = response.id
        label = AdditionalDataService.shared.getActivity(byId: response.id)?.label
        title = response.title
        location = response.destination.name
        durationMinutes = response.durationMinutes
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
                description: "\($0.minParticipants) - \($0.maxParticipants) person",
                price: "Rp \($0.pricePerPerson.formatted(.number.locale(Locale(identifier: "id_ID"))))",
                pricePerPerson: $0.pricePerPerson,
                minParticipants: $0.minParticipants,
                maxParticipants: $0.maxParticipants,
                id: $0.id,
                hostName: $0.host?.name ?? "Unknown Host"
            )
        }
        
        let groupedPackages = Dictionary(grouping: allPackages, by: { $0.hostName })
        
        availablePackages = ActivitySectionLayout(
            title: "Available Packages",
            content: groupedPackages
        )
        
        hiddenPackages = Array(allPackages.prefix(2))
        
        let lowestPriceValue = response.packages.min(by: { $0.pricePerPerson < $1.pricePerPerson })?.pricePerPerson
        
        if let price = lowestPriceValue {
            let formattedPrice = PriceFormatting.formattedIndonesianDecimal(from: "\(price)")
            self.lowestPriceFormatted = "Rp \(formattedPrice)"
        } else {
            self.lowestPriceFormatted = nil
        }
    }
}

struct ActivitySectionLayout<T: Equatable>: Equatable {
    let title: String
    let content: T
}
