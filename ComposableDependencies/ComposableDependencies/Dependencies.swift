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
class PlaceholderUserManager: UserManaging {
    let token = "WR0NG_T4K3N"

    func update(user: String) async throws -> Bool {
        return false
    }
}

private enum UserManagerKey: DependencyKey {
    static let liveValue: UserManaging = PlaceholderUserManager()
}

extension DependencyValues {
    var userManager: UserManaging {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
}
