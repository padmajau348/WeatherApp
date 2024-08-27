//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation

struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: MainWeatherData
    let name: String
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

extension Weather {
    var iconURL: URL {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
    }
}

struct MainWeatherData: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}
