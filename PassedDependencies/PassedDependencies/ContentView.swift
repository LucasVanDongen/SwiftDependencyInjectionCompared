//
//  ContentView.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import SwiftUI

struct AuthenticatedView: View {
    let dependencies: AuthenticatedDependenciesContaining

    var body: some View {
        Text(dependencies.token)
    }
}

struct LogInView: View {
    let dependencies: LogInDependenciesContaining

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
                let token = try await dependencies.authentication.authenticate()
                dependencies.logInSwitcher.tokenPublisher.send(token)
            } catch let error {

            }
        }
    }
}

import Combine
import SharedDependencies

class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    let logInDependencies: LogInDependenciesContaining

    init(logInDependencies: LogInDependenciesContaining) {
        self.logInDependencies = logInDependencies
    }

    func observe(logInSwitcher: LogInSwitching) {
        logInSwitcher.tokenPublisher
            .map(AppState.authenticated(token:))
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
}

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
        Self._logChanges()
        switch viewModel.state {
        case let .authenticated(token):
            // Watch out: the dependencies get recreated every time the View gets re-rendered
            // Is this what you really want? Only when your dependencies are truly stateless!
            let dependencies = AuthenticatedDependencies(token: token)
            return AnyView(AuthenticatedView(dependencies: dependencies))
        case .loggedOut:
            return AnyView(LogInView(dependencies: logInDependencies)
                .onAppear {
                    viewModel.observe(logInSwitcher: logInDependencies.logInSwitcher)
                })
        }
    }
}

struct ContentView: View {
    var body: some View {
        AppView(dependencies: LogInDependencies())
    }
}

#Preview {
    ContentView()
}
