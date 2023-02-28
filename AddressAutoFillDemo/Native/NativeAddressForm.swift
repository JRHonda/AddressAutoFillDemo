//
//  NativeAddressForm.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/24/23.
//

import SwiftUI

struct NativeAddressForm: View {

    @StateObject private var viewModel = NativeAddressViewModel()
    @State private var address = Address()
    @FocusState private var isFocused: Bool
    @State private var userSelectedAnAddressSuggestion = false
    @State private var userWantsToEnterAddressManually = false
    private let onSubmit: (() -> Void)?

    init(onSubmit: (() -> Void)?) {
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            Section("Enter address below") {
                TextField("Address", text: $address.addressLine1)
                    .focused($isFocused)
                    .onChange(of: address.addressLine1) {
                        if isFocused
                            && userSelectedAnAddressSuggestion == false
                            && userWantsToEnterAddressManually == false {
                            viewModel.addressInput.send($0)
                        }
                        userSelectedAnAddressSuggestion = false
                    }

                addressSuggestions

                TextField("City", text: $address.city)
                TextField("State", text: $address.state)
                TextField("Zip", text: $address.zip)
                    .keyboardType(.numberPad)

                onSubmitButton
            }
        }
    }

    @ViewBuilder
    private var addressSuggestions: some View {
        if viewModel.locationCompletions.isEmpty == false
            && isFocused == true
            && userWantsToEnterAddressManually == false {
            ForEach(viewModel.locationCompletions, id: \.self) { localSearchCompletion in
                Button {
                    withAnimation {
                        viewModel.addressSuggester.reverseGeocode(location: localSearchCompletion) {
                            userSelectedAnAddressSuggestion = true
                            isFocused = false
                            address = $0
                            viewModel.locationCompletions = []
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(localSearchCompletion.title)
                        Text(localSearchCompletion.subtitle)
                            .font(.system(.caption))
                    }
                }
            }

            Button("I want to enter address manually") {
                withAnimation {
                    userWantsToEnterAddressManually = true
                }
            }
            .foregroundColor(.red)
        }
    }

    @ViewBuilder
    private var onSubmitButton: some View {
        Button("Submit") {
            onSubmit?()
            viewModel.locationCompletions = []
        }
        .frame(maxWidth: .infinity)
        .disabled(onSubmit == nil)
    }

}

struct NativeAddressForm_Previews: PreviewProvider {
    static var previews: some View {
        NativeAddressForm(onSubmit: nil)
    }
}

import Combine
import MapKit
final class NativeAddressViewModel: ObservableObject {

    @Published var locationCompletions = [MKLocalSearchCompletion]()
    let addressInput = PassthroughSubject<String, Never>()

    var addressSuggester: MKLocalSearchService
    private var tasks = Set<AnyCancellable>()

    init() {
        self.addressSuggester = MKLocalSearchService()

        addressInput.receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.isEmptyString == false }
            .compactMap { [weak self] in
                self?.addressSuggester.initiateAddressSuggestionsSearch(from: $0)
            }
            .sink {
                $0.replaceError(with: [])
                    .assign(to: &self.$locationCompletions)
            }
            .store(in: &tasks)
    }

}
