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

    var logInSwitcher: Factory<LogInSwitching> {
        self { LogInSwitcher() }.singleton
    }

    var userManager: Factory<UserManaging> {
        self { PlaceholderUserManager() }.singleton
    }
}

// This implementation is used to prevent a `nil` value for this dependency while the user is not authenticated yet
class PlaceholderUserManager: UserManaging {
    let token = "WR0NG_T0K3N"

    func update(user: String) async throws -> Bool {
        return false
    }
}
