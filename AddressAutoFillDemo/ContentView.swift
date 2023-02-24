//
//  ContentView.swift
//  AddressAutoFillDemo
//
//  Created by Justin Honda on 2/22/23.
//

import Combine
import MapKit
import SwiftUI

struct ContentView: View {
    
    private enum TabTag: String, PascalCaseRepresentable {
        case native, smartyStreets, mapBox
    }
    
    @State private var tabSelectedTitle: String = TabTag.native.rawValue
    @State private var tabTag: TabTag = .native
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabTag) {
                nativeTabItemView
                smartyStreetsTabItemView
                mapBoxTabItemView
            }
            .onChange(of: tabTag) { tabTag in
                withAnimation {
                    tabSelectedTitle = tabTag.rawValue
                }
            }
            .navigationTitle(tabSelectedTitle)
        }
        .navigationBarTitleDisplayMode(.large)
    }

    private var nativeTabItemView: some View {
        // TODO: - Maybe add an AddressSubmitFormView for the Native solution
        NativeAddressForm(onSubmit: nil)
            .tabItem {
                Image(systemName: "swift")
                Text(TabTag.native.rawValue)
            }
            .tag(TabTag.native)
    }

    private var smartyStreetsTabItemView: some View {
        AddressSubmitFormView(addressSuggester: SmartyService())
            .tabItem {
                Image(systemName: "road.lanes.curved.right")
                Text(TabTag.smartyStreets.rawValue)
            }
            .tag(TabTag.smartyStreets)
    }

    private var mapBoxTabItemView: some View {
        AddressSubmitFormView(addressSuggester: MapBoxService())
            .tabItem {
                Image(systemName: "map")
                Text(TabTag.mapBox.rawValue)
            }
            .tag(TabTag.mapBox)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
