//
//  MapBoxTests.swift
//  AddressAutoFillDemoTests
//
//  Created by Justin Honda on 2/27/23.
//

@testable import AddressAutoFillDemo
import Combine
import XCTest

final class MapBoxTests: XCTestCase {

    private var mapBoxService = MapBoxService()
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
     Test Case '-[AddressAutoFillDemoTests.MapBoxTests testMeasure_MonotonicClock]' measured [Clock Monotonic Time, s] average: 0.456, relative standard deviation: 5.494%, values: [0.466805, 0.426168, 0.428525, 0.472883, 0.478505, 0.434474, 0.472533, 0.487846, 0.475864, 0.416287]
     */
    func testMeasure_MonotonicClock() throws {
        let address = "1 Infi"

        measure(options: options) {
            let expectation = self.expectation(description: "")

            mapBoxService.suggestAddresses(from: address)
                .replaceError(with: [])
                .sink {
                    if $0.isEmpty == false {
                        expectation.fulfill()
                    }
                }
            .store(in: &subscriptions)

            wait(for: [expectation], timeout: 3)
        }
    }

    /**
     Accepted baseline results:
     Test Case '-[AddressAutoFillDemoTests.MapBoxTests testMeasure_WallTimeClock]' measured [Time, seconds] average: 0.568, relative standard deviation: 47.818%, values: [1.378197, 0.517388, 0.462635, 0.499953, 0.421170, 0.482495, 0.501897, 0.491373, 0.450926, 0.471022]
     */
    func testMeasure_WallTimeClock() throws {
        let address = "1 Infi"

        measure {
            let expectation = self.expectation(description: "")

            mapBoxService.suggestAddresses(from: address)
                .replaceError(with: [])
                .sink {
                    if $0.isEmpty == false {
                        expectation.fulfill()
                    }
                }
            .store(in: &subscriptions)

            wait(for: [expectation], timeout: 3)
        }
    }

}
