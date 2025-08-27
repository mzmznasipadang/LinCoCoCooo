//
//  MyTripListCardDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation

struct MyTripListCardDataModel {
    let statusLabel: StatusLabel
    let imageUrl: String
    let dateText: String
    let title: String
    let location: String
    let totalPax: Int
    let price: String
    let packageType: String
    
    struct StatusLabel {
        let text: String
        let style: CocoStatusLabelStyle
    }
    
    init(bookingDetail: BookingDetails) {
        var bookingStatus: String = bookingDetail.status
        var statusStyle: CocoStatusLabelStyle = .pending
        var formattedDate: String = bookingDetail.activityDate
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let targetDate = inputFormatter.date(from: bookingDetail.activityDate) {
            let today = Date()
            
            if targetDate < today {
                bookingStatus = "Completed"
                statusStyle = .success
            } else if targetDate > today {
                bookingStatus = "Upcoming"
                statusStyle = .refund
            }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "E, d MMM yyyy"
            formattedDate = outputFormatter.string(from: targetDate)
        }
        
        statusLabel = StatusLabel(text: bookingStatus, style: statusStyle)
        imageUrl = bookingDetail.destination.imageUrl ?? ""
        dateText = formattedDate
        title = bookingDetail.activityTitle
        location = bookingDetail.destination.name
        totalPax = bookingDetail.participants
        price = "Rp \(bookingDetail.totalPrice)"
        packageType = bookingDetail.packageName
    }
}
