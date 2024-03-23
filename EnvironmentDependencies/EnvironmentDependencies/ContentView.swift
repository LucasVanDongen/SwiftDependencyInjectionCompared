//
//  ContentView.swift
//  EnvironmentDependencies
//
//  Created by Lucas van Dongen on 15/03/2024.
//

import SharedDependencies
import SwiftUI

private struct AuthenticationEnvironmentKey: EnvironmentKey {
    static let defaultValue: Authenticating = Authentication()
}

private struct UserManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserManaging = PlaceholderUserManager()
}

private struct LogInSwitcherEnvironmentKey: EnvironmentKey {
    static let defaultValue: LogInSwitching = LogInSwitcher()
}

extension EnvironmentValues {
    var authentication: Authenticating {
        get { self[AuthenticationEnvironmentKey.self] }
        set { self[AuthenticationEnvironmentKey.self] = newValue }
    }
    var userManager: UserManaging {
        get { self[UserManagerEnvironmentKey.self] }
        set { self[UserManagerEnvironmentKey.self] = newValue }
    }
    var logInSwitcher: LogInSwitching {
        get { self[LogInSwitcherEnvironmentKey.self] }
        set { self[LogInSwitcherEnvironmentKey.self] = newValue }
    }
}

@MainActor
struct AuthenticatedView: View {
    @Environment(\.logInSwitcher) private var logInSwitcher: LogInSwitching

    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            // Here, we need to assume the right environment values were set the moment we got the token
            // If we would have multiple Views consuming the same dependencies, it would save a lot of work
            // When not set, we would have a crash here
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

    @Environment(\.userManager) private var userManager: UserManaging

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

    @Environment(StoryFetcher.self) private var storyFetcher: StoryFetcher

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
    @Environment(\.authentication) private var authentication: Authenticating
    @Environment(\.logInSwitcher) private var logInSwitcher: LogInSwitching

    @State private var isAuthenticating = false

    var body: some View {
        switch isAuthenticating {
        case true:
            Text("Authenticating...")
        case false:
            VStack {
                Text("You are logged out now")
                Button {
                    Task.detached {
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

@MainActor
class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    init(logInSwitcher: LogInSwitching) {
        Task.detached { [weak self] in
            await self?.observe(logInSwitcher: logInSwitcher)
        }
    }

    private func observe(logInSwitcher: LogInSwitching) async {
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

    var body: some View {
        switch viewModel.state {
        case let .authenticated(token):
            // AppView is now responsible for passing the right dependencies into `environment` or `environmentObject`
            // Failing to set the `UserManager` will result in the `PlaceholderUserManager` being used
            // Failing to set the `StoryFetcher` will result in a crash when it's accessed
            // It does work really well to keep certain dependencies only in one part of the tree
            AuthenticatedView()
                .environment(\.userManager, UserManager(token: token))
                .environment(StoryFetcher(token: token))
        case .loggedOut:
            LogInView()
        }
    }
}

@MainActor
struct ContentView: View {
    @Environment(\.logInSwitcher) private var logInSwitcher: LogInSwitching

    var body: some View {
        AppView(viewModel: AppViewModel(logInSwitcher: logInSwitcher))
    }
}

#Preview {
    ContentView()
}
