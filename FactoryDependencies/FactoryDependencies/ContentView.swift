//
//  ContentView.swift
//  FactoryDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import Factory
import SwiftUI

struct AuthenticatedView: View {
    @Injected(\.userManager) var userManager

    var body: some View {
        Text(userManager.token)
    }
}

struct LogInView: View {
    @Injected(\.authentication) var authentication
    @Injected(\.logInSwitcher) var logInSwitcher

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
    @Injected(\.logInSwitcher) private var logInSwitcher

    @Published private(set) var state: AppState = .loggedOut

    private var cancelBag = Set<AnyCancellable>()

    init() {
        observe(logInSwitcher: logInSwitcher)
        observeState()
    }

    func observe(logInSwitcher: LogInSwitching) {
        logInSwitcher.tokenPublisher
            .map(AppState.authenticated(token:))
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    func observeState() {
        $state.map { state in
            switch state {
            case let .authenticated(token):
                UserManager(token: token)
            case .loggedOut:
                PlaceholderUserManager()
            }
        }.sink { userManager in
            Container.shared.userManager.register { userManager }
        }.store(in: &cancelBag)
    }
}

struct AppView: View {
    @StateObject var viewModel = AppViewModel() // No dependencies needed

    var body: some View {
        Self._logChanges()

        // Dependencies are not passed
        switch viewModel.state {
        case .authenticated:
            return AnyView(AuthenticatedView())
        case .loggedOut:
            return AnyView(LogInView())
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
