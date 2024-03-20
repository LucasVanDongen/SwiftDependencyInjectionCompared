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
        self { PlaceholderUserManager() }.singleton
    }

    var storyFetcher: Factory<any StoryFetching> {
        self { PlaceholderStoryFetcher() }.singleton
    }
}

// This implementation is used to prevent a `nil` value for this dependency while the user is not authenticated yet
final class PlaceholderUserManager: UserManaging {
    let token = "WR0NG_T0K3N"

    func update(user: String) async throws -> Bool {
        return false
    }
}

final class PlaceholderStoryFetcher: StoryFetching {
    // You have an issue if this function would actually be called
    func fetchStories() async throws -> [Story] {
        return []
    }
}

class AuthenticatedDependenciesManager {
    static func handle(token: String) {
        switch token.isEmpty {
        case true: deregister()
        case false: register(with: token)
        }
    }

    static func deregister() {
        Container.shared.userManager.register { PlaceholderUserManager() }
        Container.shared.storyFetcher.register { PlaceholderStoryFetcher() }
    }

    static func register(with token: String) {
        Container.shared.userManager.register { UserManager(token: token) }
        Container.shared.storyFetcher.register { StoryFetcher(token: token) }
    }
}
