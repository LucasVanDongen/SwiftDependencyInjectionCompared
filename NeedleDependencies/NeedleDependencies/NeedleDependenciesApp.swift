//
//  NeedleDependenciesApp.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import SwiftUI

@main
struct NeedleDependenciesApp: App {
    init() {
        registerProviderFactories()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
