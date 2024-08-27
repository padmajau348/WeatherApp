//
//  CityResponse.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation

struct City: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
}

extension City {
    var formattedName: String {
        let displayValues: [String] = [name, state, country].compactMap({$0})
        return displayValues.joined(separator: ", ")
    }
}
