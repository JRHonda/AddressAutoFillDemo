//
//  MapBoxService.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Combine
import Foundation
// import MapBox

final class MapBoxService {

    var addressSuggestions = PassthroughSubject<[Address], Error>()

}

extension MapBoxService: AddressSuggester {

    func suggestAddresses(from input: String) {
        // Not yet implemented
    }

}
