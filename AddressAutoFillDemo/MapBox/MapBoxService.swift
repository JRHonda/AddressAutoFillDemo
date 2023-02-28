//
//  MapBoxService.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Combine
import CoreLocation
import Foundation
import MapboxSearch

/// For Xcode Cloud we'll need to set up a simple script to replicate the instructions for resolving the MapBox API SPM
/** Possible script (NOTE: we'll need to add MAPBOX_TOKEN secret token to the workflow environment):
 #!/bin/bash

  touch ~/.netrc

 echo "machine api.mapbox.com" > ~/.netrc
 echo "login mapbox" >> ~/.netrc
 echo "password ${MAPBOX_TOKEN}" >> ~/.netrc
 */
final class MapBoxService: NSObject, CLLocationManagerDelegate {

    private var locationManager: CLLocationManager

    private lazy var addressAutoFill: AddressAutofill = {
        let accessToken = "pk.eyJ1IjoianVzdGluaG9uZGEiLCJhIjoiY2xlaXg5dWpqMDV0ZjNvbm1obXE3N3h3aSJ9.WzhIAbLvoY6sAQDUOUtL5g"
        let provider = DefaultLocationProvider(locationManager: locationManager)
        let addressAutoFill = AddressAutofill(accessToken: accessToken, locationProvider: provider)
        return addressAutoFill
    }()

    private let addressAutoFillOptions = AddressAutofill.Options(
        countries: [.init(countryCode: "US")!],
        language: .init(locale: .autoupdatingCurrent)
    )

    override init() {
        locationManager = .init()

        super.init()

        locationManager.delegate = self

        DispatchQueue.global(qos: .background).async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.requestWhenInUseAuthorization()
            }
        }

        locationManager.startUpdatingLocation()
    }

}

// MARK: - AddressSuggester

extension MapBoxService: AddressSuggester {

    func suggestAddresses(from input: String) -> Future<[Address], Error> {
        .init { [weak self] promise in
            guard let query = AddressAutofill.Query(value: input) else {
                promise(.success([]))
                return
            }

            self?.addressAutoFill.suggestions(for: query, with: self?.addressAutoFillOptions) { result in
                switch result {
                case .success(let suggestions):
                    var addresses = [Address]()
                    for suggestion in suggestions {
                        let addressComponents = suggestion.result().addressComponents.all

                        let houseNumber = addressComponents.first { $0.kind == .houseNumber }?.value ?? ""
                        let streetName = addressComponents.first { $0.kind == .street }?.value ?? ""
                        let addressLine1 = "\(houseNumber) \(streetName)".trimmingCharacters(in: .whitespaces)

                        let address = Address(
                            addressLine1: addressLine1,
                            addressLine2: "",
                            city: addressComponents.first { $0.kind == .place }?.value ?? "",
                            state: addressComponents.first { $0.kind == .region }?.value ?? "",
                            zip: addressComponents.first { $0.kind == .postcode }?.value ?? ""
                        )

                        addresses.append(address)
                    }

                    promise(.success(addresses))
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    promise(.failure(error))
                }
            }
        }

    }

}
