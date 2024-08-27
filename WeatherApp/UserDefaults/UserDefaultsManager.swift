//
//  UserDefaultsManager.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import Foundation

class UserDefaultsManager {

    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard

    private init() {}

    // Save City object to UserDefaults
    func saveCity(_ city: City, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(city)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to encode city: \(error.localizedDescription)")
        }
    }

    // Retrieve City object from UserDefaults
    func getCity(forKey key: String) -> City? {
        guard let data = userDefaults.data(forKey: key) else {
            print("No data found for key: \(key)")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let city = try decoder.decode(City.self, from: data)
            return city
        } catch {
            print("Failed to decode city: \(error.localizedDescription)")
            return nil
        }
    }

    // Remove City object from UserDefaults
    func removeCity(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
