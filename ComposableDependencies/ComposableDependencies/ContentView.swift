//
//  ContentView.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 04/03/2024.
//

import ComposableArchitecture
import SharedDependencies
import SwiftUI

@MainActor
struct AuthenticatedView: View {
    let store: StoreOf<AuthenticatedFeature>

    let userManagementFeature = Store(initialState: UserManagementFeature.State.loaded) {
        UserManagementFeature()
    }
    let storiesFeature = Store(initialState: StoriesFeature.State.loading) {
        StoriesFeature()
    }

    var body: some View {
        VStack {
            UserManagementView(store: userManagementFeature)
            StoriesView(store: storiesFeature)
            Button {
                store.send(.logOut)
            } label: {
                Text("Log Out")
            }
        }
    }
}

@MainActor
struct UserManagementView: View {
    let store: StoreOf<UserManagementFeature>

    @Dependency(\.userManager) var userManager

    var body: some View {
        VStack {
            Text("You are logged in with token \(userManager.token)")

            switch store.state {
            case .loaded:
                Button {
                    store.send(.update)
                } label: {
                    Text("Update User")
                }
            case .updating:
                Text("Updating User...")
            case let .failed(reason):
                Text("Failed updating User:\n\(reason)")
            case .updated:
                Text("You have updated your user successfully")
            }
        }
    }
}

@MainActor
struct StoriesView: View {
    let store: StoreOf<StoriesFeature>

    var body: some View {
        switch store.state {
        case .loading:
            Text("Fetching stories...")
                .task {
                    store.send(.startLoading)
                }
        case let .failed(reason):
            Text("Failed fetching stories:\n\(reason)")
        case let .loaded(stories):
            List {
                ForEach(stories, id: \.name) { story in
                    Text("Author: \(story.author)\nName: \(story.name)")
                }
            }
        }
    }
}

@MainActor
struct LogInView: View {
    let store: StoreOf<LogInFeature>

    var body: some View {
        switch store.state {
        case .authenticating:
            Text("Authenticating...")
        case .waiting:
            VStack {
                Text("You are logged out now")
                Button {
                    store.send(.logIn)
                } label: {
                    Text("Log In")
                }
            }
        }
    }
}

@MainActor
struct AppView: View {
    let store: StoreOf<Features>

    var body: some View {
        switch store.state {
        case let .authenticated(state):
            let store = Store(initialState: state) {
                AuthenticatedFeature()
                    .dependency(\.userManager, UserManager(token: state.token))
                    .dependency(\.storyFetcher, StoryFetcher(token: state.token))
            }
            AuthenticatedView(store: store)
        case let .logIn(state):
            let store = Store(initialState: state) {
                LogInFeature(parentStore: self.store)
            }
            LogInView(store: store)
        }
    }
}

@MainActor
struct ContentView: View {
    let store: StoreOf<Features>

    init() {
        let authState = LogInFeature.State.waiting
        let featureState = Features.State.logIn(authState)

        store = Store(initialState: featureState) {
            Features()._printChanges()
        }
    }

    var body: some View {
        AppView(store: store)
    }
}

#Preview {
    ContentView()
}
