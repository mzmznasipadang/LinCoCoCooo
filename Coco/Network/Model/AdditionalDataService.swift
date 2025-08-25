//
//  AdditionalData.swift
//  Coco
//
//  Created by Marcelinus Gerardo on 22/08/25.
//

import Foundation

struct AdditionalData: Codable {
    let id: Int
    let title: String
    let label: String
    let highlights: String
    let activities: String
}

public class AdditionalDataService {
    static let shared = AdditionalDataService()
    
    private var activities: [AdditionalData] = []
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "additional", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to locate or load additional.json")
            return
        }
        
        do {
            activities = try JSONDecoder().decode([AdditionalData].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    func getActivity(byId id: Int) -> AdditionalData? {
        return activities.first { $0.id == id }
    }
    
    func getAllActivities() -> [AdditionalData] {
        return activities
    }
}
