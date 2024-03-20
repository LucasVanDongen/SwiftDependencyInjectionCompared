//
//  ContentView.swift
//  FactoryDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import Factory
import SharedDependencies
import SwiftUI

@MainActor
struct AuthenticatedView: View {
    @Injected(\.logInSwitcher) private var logInSwitcher

    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            // No dependencies are passed here, making it easier to modularize your application
            UserManagementView()
            StoriesView()
            Button {
                isLoggingOut = true
            } label: {
                Text("Log Out")
            }.task(id: isLoggingOut, priority: .high) {
                guard isLoggingOut else {
                    return
                }

                defer {
                    isLoggingOut = false
                }

                await logInSwitcher.loggedOut()
            }
        }
    }
}

@MainActor
struct UserManagementView: View {
    private enum ViewState: Equatable {
        case loaded
        case updating
        case failed(reason: String)
        case updated
    }

    @State private var state: ViewState = .loaded

    @Injected(\.userManager) private var userManager

    var body: some View {
        VStack {
            Text("You are logged in with token \(userManager.token)")

            switch state {
            case .loaded:
                Button {
                    state = .updating
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
        }.task(id: state, priority: .high) {
            guard state == .updating else {
                return
            }

            do {
                _ = try await userManager.update(user: "")
                state = .updated
            } catch {
                // Ignore for now
            }
        }
    }
}

@MainActor
struct StoriesView: View {
    private enum LoadingState {
        case fetching
        case failed(reason: String)
        case fetched(stories: [Story])
    }

    @State private var state: LoadingState = .fetching

    @Injected(\.storyFetcher) private var storyFetcher

    var body: some View {
        switch state {
        case .fetching:
            Text("Fetching stories...")
                .task {
                    state = .fetching
                    do {
                        let stories = try await storyFetcher.fetchStories()
                        state = .fetched(stories: stories) // You can safely mutate state properties from any thread.
                    } catch let error {
                        state = .failed(reason: error.localizedDescription)
                    }
                }
        case let .failed(reason):
            Text("Failed fetching stories:\n\(reason)")
        case let .fetched(stories):
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
    @Injected(\.authentication) private var authentication
    @Injected(\.logInSwitcher) private var logInSwitcher

    @State private var isAuthenticating = false

    var body: some View {
        switch isAuthenticating {
        case true:
            VStack {
                Text("Authenticating...")
            }
        case false:
            VStack {
                Text("You are logged out now")
                Button {
                    Task {
                        await authenticate()
                    }
                } label: {
                    Text("Log In")
                }
            }
        }
    }

    private func authenticate() async {
        isAuthenticating = true

        defer {
            isAuthenticating = false
        }

        do {
            let token = try await authentication.authenticate()
            await logInSwitcher.tokenChannel.send(token)
        } catch {
            // Not implemented
        }
    }
}

import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    @Injected(\.logInSwitcher) private var logInSwitcher

    private var cancelBag = Set<AnyCancellable>()

    init() {
        Task.detached { [weak self] in
            guard
                let self
            else {
                return
            }

            await observe(logInSwitcher: await logInSwitcher)
        }
    }

    private func observe(logInSwitcher: any LogInSwitching) async {
        for await token in logInSwitcher.tokenChannel {
            // First assign the dependencies
            AuthenticatedDependenciesManager.handle(token: token)

            // Then flip the UI switch
            state = switch token.isEmpty {
            case true: .loggedOut
            case false: .authenticated(token: token)
            }

            // If I would have these two steps reversed it would be broken, so slightly brittle
        }
    }
}

@MainActor
struct AppView: View {
    @StateObject var viewModel = AppViewModel() // No dependencies needed

    var body: some View {
        // Dependencies are not passed
        switch viewModel.state {
        case .authenticated:
            AuthenticatedView()
        case .loggedOut:
            LogInView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        AppView()
    }
}

#Preview {
    ContentView()
}
