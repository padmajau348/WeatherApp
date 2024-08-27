//
//  OpenWeatherAPI.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation
import Combine

protocol OpenWeatherAPIProtocol {
    func fetchWeatherData(lat: Double, lon: Double) -> AnyPublisher<WeatherResponse, Error>
    func fetchCities(for query: String) -> AnyPublisher<[City], Error>
}

class OpenWeatherAPI: OpenWeatherAPIProtocol {
    static let shared = OpenWeatherAPI()

    private let apiKey = "7c0f0d771860b3eeb1840a77468336ac"
    private var urlSession: URLSession

    // Initialize with dependency injection for URLSession
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchWeatherData(lat: Double, lon: Double) -> AnyPublisher<WeatherResponse, Error> {

        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "imperial")
        ]

        let request = URLRequest(url: urlComponents.url!)

        return urlSession.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func fetchCities(for query: String) -> AnyPublisher<[City], Error> {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "10"),  // Limit results to 10
            URLQueryItem(name: "appid", value: apiKey)
        ]

        let request = URLRequest(url: urlComponents.url!)

        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [City].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
