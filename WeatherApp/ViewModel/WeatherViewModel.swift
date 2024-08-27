//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation
import UIKit
import Combine
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var cityName: String = ""
    @Published var citiesSearchResults: [City] = []
    @Published var temperature: String = ""
    @Published var temperatureMinMax: String = ""
    @Published var feelsLike: String = ""

    @Published var humidity: String = ""
    @Published var weatherDescription: String = ""
    @Published var weatherIcon: UIImage? = nil
    @Published var errorMessage: String? = nil

    @Published private var weatherIconURL: URL? = nil

    private var cancellables = Set<AnyCancellable>()
    private let openweather: OpenWeatherAPIProtocol
    private let locationManager: LocationManagerProtocol

    init(openweather: OpenWeatherAPIProtocol = OpenWeatherAPI.shared,
         locationManager: LocationManagerProtocol = LocationManager()) {

        self.openweather = openweather
        self.locationManager = locationManager
        setupBindings()
    }

    func fetchinitialData() {
        fetchLocationBasedWeatherData()
    }

    func fetchWeatherData(for city: City) {
        fetchOpenWeatherData(for: city)
    }

    func fetchCities(for query: String) {
        fetchOpenWeatherCities(for: query)
    }
}

// MARK: Private
private extension WeatherViewModel {

    func fetchLocationBasedWeatherData() {
        if let savedCity = UserDefaultsManager.shared.getCity(forKey: "selectedCity") {
            self.fetchWeatherData(for: savedCity)
        } else {
            locationManager.requestLocation()
        }
    }

    func setupBindings() {
        locationManager.cityResultPublisher
            .sink { [weak self] city in
                self?.fetchWeatherData(for: city)
            }
            .store(in: &cancellables)

        $weatherIconURL
            .compactMap { $0 } // Filter out nil values
            .flatMap { url -> AnyPublisher<UIImage?, Never> in
                // Fetch the image from URL
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map { data, _ in UIImage(data: data) }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.weatherIcon, on: self)
            .store(in: &cancellables)
    }

    func updateUI(with weatherReasponse: WeatherResponse) {

        let mainWeather = weatherReasponse.main

        self.temperature = "\(mainWeather.temp)°"
        self.temperatureMinMax = "\(mainWeather.tempMax)° / \(mainWeather.tempMin)°"
        self.feelsLike = "\(mainWeather.feelsLike)°"

        self.humidity = "\(mainWeather.humidity)%"
        if let weather = weatherReasponse.weather.first {
            self.weatherDescription = weather.main.localizedCapitalized
            self.weatherIconURL = weather.iconURL
        }
    }
}

// MARK: OpenWeather

private extension WeatherViewModel {
    func fetchOpenWeatherData(for city: City) {
        self.cityName = city.formattedName

        openweather.fetchWeatherData(lat: city.lat, lon: city.lon)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.errorMessage = "Failed to fetch weather data"
                }
            }, receiveValue: { [weak self] data in
                self?.updateUI(with: data)
                UserDefaultsManager.shared.saveCity(city, forKey: "selectedCity")
            })
            .store(in: &cancellables)
    }


    func fetchOpenWeatherCities(for query: String) {
        openweather.fetchCities(for: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to fetch Cities"
                }
            }, receiveValue: { [weak self] cities in
                self?.citiesSearchResults = cities.map { $0 }
            })
            .store(in: &cancellables)
    }
}
