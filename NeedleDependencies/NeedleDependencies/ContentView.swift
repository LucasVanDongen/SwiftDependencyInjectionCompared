//
//  ContentView.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import SwiftUI

struct AuthenticatedView: View {
    let userManager: UserManaging

    var body: some View {
        Text(userManager.token)
    }
}

struct LogInView: View {
    let authentication: Authenticating
    let logInSwitcher: LogInSwitching

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

enum AppState {
    case loggedOut
    case authenticated(token: String)
}

class AppViewModel: ObservableObject {
    @Published private(set) var state: AppState = .loggedOut

    private let logInSwitcher: LogInSwitching

    init(logInSwitcher: LogInSwitching) {
        self.logInSwitcher = logInSwitcher

        observe(logInSwitcher: logInSwitcher)
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

    let logInComponent: LogInComponent
    let rootComponent: RootComponent

    var body: some View {
        switch viewModel.state {
        case let .authenticated(token):
            let authenticatedComponent = rootComponent.authenticatedComponent(token: token)
            return AnyView(authenticatedComponent.authenticatedView)
        case .loggedOut:
            return AnyView(logInComponent.logInView)
        }
    }
}

struct ContentView: View {
    let rootComponent = RootComponent()

    var body: some View {
        rootComponent.appView
    }
}

#Preview {
    ContentView()
}
