//
//  AddressForm.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/23/23.
//

import SwiftUI

struct AddressForm: View {

    @Binding var address: Address
    @StateObject private var viewModel: AddressFormViewModel
    @FocusState private var isFocused: Bool
    @State private var userSelectedAnAddressSuggestion = false
    @State private var userWantsToEnterAddressManually = false
    private let onSubmit: (() -> Void)?

    init(viewModel: AddressFormViewModel, address: Binding<Address>, onSubmit: (() -> Void)? = nil) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._address = address
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            Section("Enter address below") {
                TextField("Address", text: $address.addressLine1)
                    .focused($isFocused)
                    .onChange(of: address.addressLine1) {
                        if isFocused && userSelectedAnAddressSuggestion == false && userWantsToEnterAddressManually == false {
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
        if viewModel.addressSuggestions.value.isEmpty == false && isFocused == true && userWantsToEnterAddressManually == false {
            ForEach(viewModel.addressSuggestions.value) { addressSuggestion in
                Button {
                    withAnimation {
                        userSelectedAnAddressSuggestion = true
                        isFocused = false
                        address = addressSuggestion
                        viewModel.addressSuggestions.send([])
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("\(addressSuggestion.addressLine1)")
                            .font(.body.bold())
                        Text("\(addressSuggestion.city), \(addressSuggestion.state) \(addressSuggestion.zip)")
                            .font(.caption)
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
            viewModel.addressSuggestions.send([])
        }
        .frame(maxWidth: .infinity)
        .disabled(onSubmit == nil)
    }
}

struct AddressForm_Previews: PreviewProvider {
    static var previews: some View {
        AddressForm(
            viewModel: .init(addressSuggester: AddressSuggester_ForPreviews()),
            address: .constant(.init())
        )
    }
}

import Combine
private class AddressSuggester_ForPreviews: AddressSuggester {
    var addressSuggestions = PassthroughSubject<[Address], Error>()
    func suggestAddresses(from input: String) { }
}

final class AddressFormViewModel: ObservableObject {

    var addressSuggestions = CurrentValueSubject<[Address], Error>([])
    let addressInput = PassthroughSubject<String, Never>()

    private var addressSuggester: AddressSuggester
    private var subscriptions = Set<AnyCancellable>()

    init(addressSuggester: AddressSuggester) {
        self.addressSuggester = addressSuggester

        addressInput.receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.isEmptyString == false }
            .sink { [weak self] in
                self?.addressSuggester.suggestAddresses(from: $0)
            }
            .store(in: &subscriptions)

        addressSuggester.addressSuggestions
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Address Suggester failed with error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] in
                self?.addressSuggestions.send($0)
            }
            .store(in: &subscriptions)
    }

}
