//
//  MKLocalSearchService.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Combine
import Foundation
import MapKit

final class MKLocalSearchService: NSObject {

    private lazy var clGeocoder = CLGeocoder()

    private lazy var searchCompleter: MKLocalSearchCompleter = {
        let searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address]
        return searchCompleter
    }()

    var addressSuggestions: Future<[MKLocalSearchCompletion], Error>.Promise?

    override init() {
        super.init()
    }

    func reverseGeocode(location completion: MKLocalSearchCompletion, completionHandler: @escaping (Address) -> Void) {
        let search = MKLocalSearch(request: .init(completion:completion))
        search.start { [weak self] response, error in
            if let error {
                let output = """
                            Error performing local search for address \(completion.title)
                            Error: \(error.localizedDescription)
                            """
                print(output)
            }

            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completionHandler(.init())
                return
            }

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self?.clGeocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first else {
                    let output = """
                                Error while attempt to reverse geocode location: \(location)
                                MKLocalSearchCompletion: \(completion)
                                """
                    print(output)
                    completionHandler(.init())
                    return
                }

                // Important to note that `placemark.name` can also result in an address. However, it often refers to the location's/address name. For
                // example, if you type in "New York" then `placemark.name` will be "City Hall" but `placemark.subThoroughfare` will have address specific
                // information like the building number (in this case "91-99"). Additionally, for the "New York" result, `placemark.thoroughfare` will contain
                // just "City Hall". So we shouldn't rely on `placemark.name`.
                let addressLine1 = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "")".trimmingCharacters(in: .whitespaces)
                let address = Address(
                    addressLine1: addressLine1,
                    addressLine2: placemark.subLocality ?? "",
                    city: placemark.locality ?? "",
                    state: placemark.administrativeArea ?? "",
                    zip: placemark.postalCode ?? ""
                )

                completionHandler(address)
            }
        }
    }

}

// MARK: - AddressSuggester

extension MKLocalSearchService {

    func initiateAddressSuggestionsSearch(from input: String) -> Future<[MKLocalSearchCompletion], Error> {
        .init { [weak self] promise in
            self?.addressSuggestions = promise
            self?.searchCompleter.queryFragment = input
        }
    }

}

// MARK: - MKLocalSearchCompleterDelegate

extension MKLocalSearchService: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        addressSuggestions?(.success(completer.results))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        addressSuggestions?(.failure(error))
    }

}
