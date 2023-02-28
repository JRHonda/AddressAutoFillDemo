//
//  SmartyStreetsTests.swift
//  AddressAutoFillDemoTests
//
//  Created by Justin Honda on 2/27/23.
//

@testable import AddressAutoFillDemo
import Combine
import XCTest

final class SmartyStreetsTests: XCTestCase {

    private var smartyService = SmartyService()
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
     Test Case '-[AddressAutoFillDemoTests.SmartyStreetsTests testMeasure_MonotonicClock]' measured [Clock Monotonic Time, s] average: 0.131, relative standard deviation: 5.484%, values: [0.114748, 0.128827, 0.126510, 0.132770, 0.136726, 0.134112, 0.136658, 0.122943, 0.137821, 0.137081]
     */
    func testMeasure_MonotonicClock() throws {
        let address = "1 Infi"

        measure(options: options) {
            let expectation = self.expectation(description: "")

            smartyService.suggestAddresses(from: address)
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
     Test Case '-[AddressAutoFillDemoTests.SmartyStreetsTests testMeasure_WallTimeClock]' measured [Time, seconds] average: 0.143, relative standard deviation: 11.525%, values: [0.191770, 0.141713, 0.133161, 0.143455, 0.137367, 0.135357, 0.131478, 0.140517, 0.137430, 0.142650]
     */
    func testMeasure_WallTimeClock() throws {
        let address = "1 Infi"

        measure {
            let expectation = self.expectation(description: "")

            smartyService.suggestAddresses(from: address)
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
