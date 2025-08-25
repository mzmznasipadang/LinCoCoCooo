//
//  HomeSearchFilterPriceRangeModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation
import SwiftUI

final class HomeSearchFilterPriceRangeModel: ObservableObject {
    @Published var minPrice: Double
    @Published var maxPrice: Double

    let range: ClosedRange<Double>
    let step: Double
    
    private let defaultMinPrice: Double
    private let defaultMaxPrice: Double
    
    init(minPrice: Double, maxPrice: Double, range: ClosedRange<Double>, step: Double = 1) {
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.range = range
        self.step = step
        self.defaultMinPrice = minPrice
        self.defaultMaxPrice = maxPrice
    }
    
    func reset() {
        minPrice = defaultMinPrice
        maxPrice = defaultMaxPrice
    }
}
