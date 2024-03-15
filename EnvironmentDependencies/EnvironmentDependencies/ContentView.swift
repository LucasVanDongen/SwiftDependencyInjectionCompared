//
//  ContentView.swift
//  EnvironmentDependencies
//
//  Created by Lucas van Dongen on 15/03/2024.
//

import SwiftUI

private struct AuthenticationEnvironmentKey: EnvironmentKey {
    static let defaultValue: Authentication = Authentication()
}


extension EnvironmentValues {
    var authentication: Authentication {
        get { self[AuthenticationEnvironmentKey.self] }
        set { self[AuthenticationEnvironmentKey.self] = newValue }
    }
}

struct AuthenticatedView: View {
    @EnvironmentObject private var userManager: UserManager

    var body: some View {
        Text(userManager.token)
    }
}

struct LogInView: View {
    @Environment(\.authentication) var authentication: Authentication
    @EnvironmentObject var logInSwitcher: LogInSwitcher

    var body: some View {
        Button {
            authenticate()
        } label: {
            Text("Log In")
        }
    }

    private func authenticate() {
        Task {
            do {
                let token = try await authentication.authenticate()
                logInSwitcher.tokenPublisher.send(token)
            } catch let error {

            }
        }
    }
}

import Combine
import SharedDependencies

class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    private let logInSwitcher: LogInSwitcher

    init(logInSwitcher: LogInSwitcher) {
        self.logInSwitcher = logInSwitcher

        observe(logInSwitcher: logInSwitcher)
    }

    private func observe(logInSwitcher: LogInSwitcher) {
        logInSwitcher.tokenPublisher
            .map(AppState.authenticated(token:))
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
}

struct AppView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        Self._logChanges()
        switch viewModel.state {
        case let .authenticated(token):
            return AnyView(
                AuthenticatedView()
                    .environmentObject(UserManager(token: token))
            )
        case .loggedOut:
            return AnyView(
                LogInView()
                    .environment(\.authentication, Authentication())
            )
        }
    }
}

struct ContentView: View {
    private let logInSwitcher = LogInSwitcher()

    var body: some View {
        AppView()
            .environmentObject(logInSwitcher)
            .environmentObject(
                AppViewModel(logInSwitcher: logInSwitcher)
            )
    }
}

#Preview {
    ContentView()
}
