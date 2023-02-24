//
//  AddressSubmitFormView.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import SwiftUI

struct AddressSubmitFormView: View {

    let addressSuggester: AddressSuggester
    @State private var address = Address()
    @State private var didSubmitAddress = false

    var body: some View {
        VStack {
            AddressForm(viewModel: .init(addressSuggester: addressSuggester), address: $address, onSubmit: {
                didSubmitAddress = true
            })
            .opacity(didSubmitAddress ? 0.25 : 1.0)
            .disabled(didSubmitAddress)

            submissionResult
        }
        .animation(.default, value: didSubmitAddress)
        .onChange(of: didSubmitAddress) {
            if $0 == false {
                address = .init()
            }
        }
    }

    @ViewBuilder
    private var submissionResult: some View {
        if didSubmitAddress {
            VStack {
                Button("Start Over") {
                    didSubmitAddress = false
                }
                .buttonStyle(.borderedProminent)

                Text(String(describing: address))
            }
            .padding()

            Divider()
        }
    }
    
}

struct AddressSubmitFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSubmitFormView(addressSuggester: SmartyService())
    }
}
