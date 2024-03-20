//
//  ContentView.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import SharedDependencies
import SwiftUI

@MainActor
struct AuthenticatedView: View {
    let dependencies: AuthenticatedDependenciesContaining

    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            // AuthenticatedView needs to know what dependencies UserManagementView and StoriesView need
            // A small burden now, but it will increase exponentially with the app's complexity
            UserManagementView(userManager: dependencies.userManager)
            StoriesView(storyFetcher: dependencies.storyFetcher)
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

                await dependencies.logInSwitcher.loggedOut()
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

    let userManager: any UserManaging

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

    let storyFetcher: any StoryFetching

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
    let dependencies: LogInDependenciesContaining

    @State private var isAuthenticating = false
    @State private var tapped = 0

    var body: some View {
        Group {
            switch isAuthenticating {
            case true:
                VStack {
                    Text("Authenticating...")
//                    Button {
//                        print("Tap \(Thread.current)")
//                        tapped += 1
//                    } label: {
//                        Text("Tapped \(tapped) times")
//                    }
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
    }

    private func authenticate() async {
        isAuthenticating = true

        defer {
            isAuthenticating = false
        }

        do {
            let token = try await dependencies.authentication.authenticate()
            await dependencies.logInSwitcher.tokenChannel.send(token)
        } catch {
            // Not implemented
        }
    }
}

@MainActor
class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    let logInDependencies: LogInDependenciesContaining

    init(logInDependencies: LogInDependenciesContaining) {
        self.logInDependencies = logInDependencies

        let logInSwitcher = logInDependencies.logInSwitcher

        Task.detached { [weak self] in
            await self?.observe(logInSwitcher: logInSwitcher)
        }
    }

    private func observe(logInSwitcher: any LogInSwitching) async {
        for await token in logInSwitcher.tokenChannel {
            state = switch token.isEmpty {
            case true: .loggedOut
            case false: .authenticated(token: token)
            }
        }
    }
}

@MainActor
struct AppView: View {
    @StateObject var viewModel: AppViewModel

    // Clearly the AppView knows a lot about logging in - too much perhaps
    private let logInDependencies: LogInDependenciesContaining

    init(
        dependencies: LogInDependencies
    ) {
        _viewModel = StateObject(wrappedValue: AppViewModel(logInDependencies: dependencies))
        self.logInDependencies = dependencies
    }

    var body: some View {
        switch viewModel.state {
        case let .authenticated(token):
            // Watch out: the dependencies get recreated every time the View gets re-rendered
            // Is this what you really want? Only when your dependencies are truly stateless!
            let dependencies = AuthenticatedDependencies(
                token: token,
                logInSwitcher: logInDependencies.logInSwitcher
            )
            return AnyView(AuthenticatedView(dependencies: dependencies))
        case .loggedOut:
            return AnyView(LogInView(dependencies: logInDependencies))
        }
    }
}

@MainActor
struct ContentView: View {
    var body: some View {
        AppView(dependencies: LogInDependencies())
    }
}

#Preview {
    ContentView()
}
