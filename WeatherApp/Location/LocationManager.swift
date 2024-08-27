//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation
import CoreLocation
import Combine

protocol LocationManagerProtocol {
    func requestLocation()
    var cityResultPublisher: AnyPublisher<City, Never> { get }
}

class LocationManager: NSObject, LocationManagerProtocol {
    public var cityResultPublisher: AnyPublisher<City, Never> {
        city.eraseToAnyPublisher()
    }

    public let city = PassthroughSubject<City, Never>()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        // Perform reverse geocoding to get the city name
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else { return }

            if let place = placemark.locality {
                DispatchQueue.main.async { [weak self] in
                    let newCity = City(name: place,
                                      lat: location.coordinate.latitude,
                                      lon: location.coordinate.longitude,
                                      country: placemark.country,
                                      state: placemark.administrativeArea)
                    self?.city.send(newCity)
                }
            } else {
                print("No city found for location.")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
