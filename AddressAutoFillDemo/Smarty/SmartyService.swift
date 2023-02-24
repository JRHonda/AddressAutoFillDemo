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

    var addressSuggestions = PassthroughSubject<[Address], Error>()

    var autoCompleteClient: USAutocompleteProClient

    init() {
        autoCompleteClient = ClientBuilder(id: "160773497573587811", hostname: "fanaticslive.address.test")
            .withLicenses(licenses: ["us-autocomplete-pro-cloud"])
            .buildUSAutocompleteProApiClient()
    }

}

// MARK: - AddressSuggester

extension SmartyService: AddressSuggester {

    func suggestAddresses(from input: String) {
        var lookup = USAutocompleteProLookup().withSearch(search: input)
        var error: NSError?

        _ = autoCompleteClient.sendLookup(lookup: &lookup, error: &error) // returns a Bool

        if let error {
            let output = """
            Domain: \(error.domain)
            Error Code: \(error.code)
            Description: \n\(error.userInfo[NSLocalizedDescriptionKey] as! NSString)
            """

            print(output)

            addressSuggestions.send([])

            return
        }

        guard let suggestions = lookup.result?.suggestions else {
            addressSuggestions.send([])
            return
        }

        addressSuggestions.send(
            suggestions.prefix(6)
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
        )
    }

}
