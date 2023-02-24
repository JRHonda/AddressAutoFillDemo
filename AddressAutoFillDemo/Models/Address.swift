//
//  Address.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Foundation

struct Address: Identifiable {
    let id = UUID()
    var addressLine1: String
    var addressLine2: String
    var city: String
    var state: String
    var zip: String
}

extension Address {
    init() {
        addressLine1 = ""
        addressLine2 = ""
        city = ""
        state = ""
        zip = ""
    }
}
