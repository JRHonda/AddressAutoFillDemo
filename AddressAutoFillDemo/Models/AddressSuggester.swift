//
//  AddressSuggester.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Combine
import Foundation
import SwiftUI

protocol AddressSuggester {
    var addressSuggestions: PassthroughSubject<[Address], Error> { get }
    // TODO: - When working on MapBox solution try to see if I can get rid of the PassthroughSubject and return [Address] from method below
    func suggestAddresses(from input: String)
}
