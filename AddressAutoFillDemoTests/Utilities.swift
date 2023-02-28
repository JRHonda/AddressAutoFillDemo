//
//  Utilities.swift
//  AddressAutoFillDemoTests
//
//  Created by Justin Honda on 2/27/23.
//

import Foundation
import XCTest

final class XCTextExpectationFullfillmentCountable: XCTestExpectation {

    private(set) var currentFullfillmentCount: Int = 0

    override init(description expectationDescription: String) {
        super.init(description: expectationDescription)
    }

    override func fulfill() {
        currentFullfillmentCount += 1
        super.fulfill()
    }

}
