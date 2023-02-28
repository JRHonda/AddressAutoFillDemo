//
//  NativeTests.swift
//  AddressAutoFillDemoTests
//
//  Created by Justin Honda on 2/27/23.
//

@testable import AddressAutoFillDemo
import Combine
import MapKit
import XCTest

final class NativeTests: XCTestCase {

    private var mkLocalSearchService = MKLocalSearchService()
    private var subscriptions = Set<AnyCancellable>()
    private var options: XCTMeasureOptions {
        let options = Self.defaultMeasureOptions
        options.iterationCount = 10
        return options
    }

    override func tearDown() {
        subscriptions.forEach { $0.cancel() }
        super.tearDown()
    }

    /**
     Accepted baseline results:
     Test Case '-[AddressAutoFillDemoTests.NativeTests testRetrieveAddressSuggestions_MonotonicClock]' measured [Clock Monotonic Time, s] average: 0.000, relative standard deviation: 28.246%, values: [0.000171, 0.000126, 0.000104, 0.000098, 0.000099, 0.000077, 0.000072, 0.000085, 0.000081, 0.000083]
     */
    func testRetrieveAddressSuggestions_MonotonicClock() throws {
        let address = "1 Infi"
        let publisher = mkLocalSearchService.initiateAddressSuggestionsSearch(from: address)
            .replaceError(with: [])

        measure(options: options) {
            let expectation = self.expectation(description: "")

            publisher.sink {
                if $0.count > 0 {
                    expectation.fulfill()
                    print(address)
                }
            }
            .store(in: &subscriptions)

            wait(for: [expectation], timeout: 3)
        }
    }

    /**
     Accepted baseline results:
     Test Case '-[AddressAutoFillDemoTests.NativeTests testRetrieveAddressSuggestions_WallTimeClock]' measured [Time, seconds] average: 0.000, relative standard deviation: 61.011%, values: [0.000424, 0.000153, 0.000127, 0.000104, 0.000106, 0.000108, 0.000095, 0.000123, 0.000110, 0.000190]
     */
    func testRetrieveAddressSuggestions_WallTimeClock() throws {
        let address = "1 Infi"
        let publisher = mkLocalSearchService.initiateAddressSuggestionsSearch(from: address)
            .replaceError(with: [])

        measure {
            let expectation = self.expectation(description: "")
            publisher.sink {
                if $0.count > 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

            wait(for: [expectation], timeout: 3)
        }
    }

}
