//
//  ComposableDependenciesApp.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 04/03/2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct ComposableDependenciesApp: App {
    @State private var store = Store(initialState: .logIn(.waiting)) {
        AppRootFeature.body
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
