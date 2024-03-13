//
//  ContentView.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 04/03/2024.
//

import ComposableArchitecture
import SwiftUI

struct AuthenticatedView: View {
    let store: StoreOf<AuthenticatedFeature>

    var body: some View {
        Text(store.token)
    }
}

struct LogInView: View {
    let store: StoreOf<LogInFeature>

    var body: some View {
        Button {
            store.send(.logIn)
        } label: {
            Text("Log In")
        }
    }
}

import SharedDependencies

struct AppView: View {
    let store: StoreOf<AppRootFeature>

    var body: some View {
        switch store.case {
        case let .authenticated(store):
            NavigationStack {
                AuthenticatedView(store: store)
            }
        case let .logIn(store):
            NavigationStack {
                LogInView(store: store)
            }
        }
    }
}

struct ContentView: View {
    let store: StoreOf<AppRootFeature>

    init() {
        let authStore = LogInFeature.State()
        let featureState = AppRootFeature.State.logIn(authStore) //  .authenticated(AuthenticatedFeature.State(token: "asdf")) 

        store = Store(initialState: featureState) {
            AppRootFeature.body._printChanges()
        }
    }

    var body: some View {
        AppView(store: store)
    }
}

#Preview {
    ContentView()
}
