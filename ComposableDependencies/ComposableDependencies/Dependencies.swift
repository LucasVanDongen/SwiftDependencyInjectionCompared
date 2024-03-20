//
//  Dependencies.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 05/03/2024.
//

import ComposableArchitecture
import SharedDependencies

private enum AuthenticationKey: DependencyKey {
    static let liveValue: Authenticating = Authentication()
}

extension DependencyValues {
    var authentication: Authenticating {
        get { self[AuthenticationKey.self] }
        set { self[AuthenticationKey.self] = newValue }
    }
}

// This implementation is used to prevent a `nil` value for this dependency while the user is not authenticated yet
final class PlaceholderUserManager: UserManaging {
    let token = "WR0NG_T4K3N"

    func update(user: String) async throws -> Bool {
        return false
    }
}

private enum UserManagerKey: DependencyKey {
    static let liveValue: any UserManaging = PlaceholderUserManager()
}

extension DependencyValues {
    var userManager: any UserManaging {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
}

final class PlaceholderStoryFetcher: StoryFetching {
    // If this function would ever be executed, we have a problem
    func fetchStories() async throws -> [Story] {
        return []
    }
}

private enum StoryFetcherKey: DependencyKey {
    static let liveValue: any StoryFetching = PlaceholderStoryFetcher()
}

extension DependencyValues {
    var storyFetcher: any StoryFetching {
        get { self[StoryFetcherKey.self] }
        set { self[StoryFetcherKey.self] = newValue }
    }
}
