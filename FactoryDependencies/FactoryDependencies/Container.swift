//
//  Container.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import Combine
import Factory
import SharedDependencies

extension Container {
    var authentication: Factory<Authenticating> {
        self { Authentication() }.singleton
    }

    var logInSwitcher: Factory<any LogInSwitching> {
        self { LogInSwitcher() }.singleton
    }

    var userManager: Factory<any UserManaging> {
        self { PlaceholderUserManager() }.graph
    }

    var storyFetcher: Factory<any StoryFetching> {
        self { PlaceholderStoryFetcher() }.graph
    }
}

class AuthenticatedDependenciesManager {
    static func handle(token: String) {
        switch token.isEmpty {
        case true: break // We're relying on the `graph` feature to dismiss `token`-based real implementations
        case false: register(with: token)
        }
    }

    static func register(with token: String) {
        Container.shared.userManager.register { UserManager(token: token) }
        Container.shared.storyFetcher.register { StoryFetcher(token: token) }
    }
}
