//
//  String+Extensions.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import Foundation

extension String {

    var isEmptyString: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }

}

protocol PascalCaseRepresentable: RawRepresentable { }

extension PascalCaseRepresentable where Self.RawValue == String {

    var rawValue: RawValue {
        let value = String(describing: self)
        guard let first = value.first else { return "" }
        return first.uppercased() + value.dropFirst()
    }
    
}
