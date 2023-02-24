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

    var locationManager: CLLocationManager

    lazy var addressAutoFill: AddressAutofill = {
        let accessToken = "pk.eyJ1IjoianVzdGluaG9uZGEiLCJhIjoiY2xlaXg5dWpqMDV0ZjNvbm1obXE3N3h3aSJ9.WzhIAbLvoY6sAQDUOUtL5g"
        let provider = DefaultLocationProvider(locationManager: locationManager)
        let addressAutoFill = AddressAutofill(accessToken: accessToken, locationProvider: DefaultLocationProvider())
        return addressAutoFill
    }()
    
    var addressSuggestions = PassthroughSubject<[Address], Error>()

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

extension MapBoxService: AddressSuggester {

    func suggestAddresses(from input: String) {
        guard let query = AddressAutofill.Query(value: input) else {
            return
        }
        addressAutoFill.suggestions(for: query, with: .init(countries: [.init(countryCode: "US")!], language: .init(locale: .autoupdatingCurrent))) { [weak self] result in
            switch result {
            case .success(let results):
                var addresses = [Address]()
                for result in results {
                    let addressComponents = result.result().addressComponents.all
                    let houseNumber = addressComponents.first { $0.kind == .houseNumber }?.value ?? ""
                    let streetName = addressComponents.first { $0.kind == .street }?.value ?? ""
                    let addressLine1 = "\(houseNumber) \(streetName)".trimmingCharacters(in: .whitespaces)
                    let city = addressComponents.first { $0.kind == .place }?.value ?? ""
                    let state = addressComponents.first { $0.kind == .region }?.value ?? ""
                    let zipCode = addressComponents.first { $0.kind == .postcode }?.value ?? ""
                    let address = Address(
                        addressLine1: addressLine1,
                        addressLine2: "",
                        city: city,
                        state: state,
                        zip: zipCode
                    )
                    addresses.append(address)
                }
                self?.addressSuggestions.send(addresses)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
