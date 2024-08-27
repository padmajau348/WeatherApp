//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Padmaja Unnam on 8/27/24.
//

import UIKit
import Combine

class WeatherViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!

    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!

    @IBOutlet weak var temperatureMinMaxLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!

    private var viewModel = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var searchController: UISearchController!
    private var citySearchResultsController: CitySearchResultsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        bindViewModel()
        viewModel.fetchinitialData()
    }

    private func setupSearchController() {
        // Initialize search results controller
        citySearchResultsController = CitySearchResultsTableViewController()
        citySearchResultsController.onCitySelected = { [weak self] city in
            self?.viewModel.fetchWeatherData(for: city)
        }

        // Initialize search controller
        searchController = UISearchController(searchResultsController: citySearchResultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Cities"

        // Integrate search controller into navigation bar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func bindViewModel() {
        viewModel.$cityName
            .map({$0 as String?})
            .assign(to: \.text, on: cityNameLabel)
            .store(in: &cancellables)

        viewModel.$temperatureMinMax
            .map({$0 as String?})
            .assign(to: \.text, on: temperatureMinMaxLabel)
            .store(in: &cancellables)

        viewModel.$feelsLike
            .map({$0 as String?})
            .assign(to: \.text, on: feelsLikeLabel)
            .store(in: &cancellables)

        viewModel.$temperature
            .map({$0 as String?})
            .assign(to: \.text, on: temperatureLabel)
            .store(in: &cancellables)

        viewModel.$humidity
            .map({$0 as String?})
            .assign(to: \.text, on: humidityLabel)
            .store(in: &cancellables)

        viewModel.$weatherDescription
            .map({$0 as String?})
            .assign(to: \.text, on: weatherDescriptionLabel)
            .store(in: &cancellables)

        viewModel.$weatherIcon
            .assign(to: \.image, on: weatherIconImageView)
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(message: message)
            }
            .store(in: &cancellables)

        viewModel.$citiesSearchResults
            .assign(to: \.filteredCities, on: citySearchResultsController)
            .store(in: &cancellables)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension WeatherViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            citySearchResultsController.filteredCities = []
            return
        }
        viewModel.fetchCities(for: searchText)
    }
}
