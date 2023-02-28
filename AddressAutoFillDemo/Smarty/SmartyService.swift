//
//  SmartyService.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Combine
import Foundation
import SmartyStreets

final class SmartyService {

    var autoCompleteClient: USAutocompleteProClient

    init() {
        autoCompleteClient = ClientBuilder(id: "160773497573587811", hostname: "fanaticslive.address.test")
            .withLicenses(licenses: ["us-autocomplete-pro-cloud"])
            .buildUSAutocompleteProApiClient()
    }

}

// MARK: - AddressSuggester

extension SmartyService: AddressSuggester {

    func suggestAddresses(from input: String) -> Future<[Address], Error> {
        .init { [weak self] promise in
            var lookup = USAutocompleteProLookup().withSearch(search: input)
            var error: NSError?

            _ = self?.autoCompleteClient.sendLookup(lookup: &lookup, error: &error) // returns a Bool

            if let error {
                let output = """
                Domain: \(error.domain)
                Error Code: \(error.code)
                Description: \n\(error.userInfo[NSLocalizedDescriptionKey] as! NSString)
                """

                print(output)

                promise(.success([]))

                return
            }

            guard let suggestions = lookup.result?.suggestions else {
                promise(.success([]))
                return
            }

            let mappedSuggestions: [Address] = suggestions/*.prefix(6)*/
                .reduce(into: []) { partialResult, suggestion in
                    let address = Address(
                        addressLine1: suggestion.streetLine ?? "",
                        addressLine2: suggestion.secondary ?? "",
                        city: suggestion.city ?? "",
                        state: suggestion.state ?? "",
                        zip: suggestion.zipcode ?? ""
                    )
                    partialResult.append(address)
                }

            promise(.success(mappedSuggestions))
        }
    }

}
