//
//  Container.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import Combine
import SharedDependencies

protocol LogInSwitching {
    var tokenPublisher: PassthroughSubject<String, Never> { get }

    func loggedIn(with token: String)
}

class LogInSwitcher: LogInSwitching {
    let tokenPublisher = PassthroughSubject<String, Never>()

    func loggedIn(with token: String) {
        tokenPublisher.send(token)
    }
}

protocol LogInDependenciesContaining {
    var authentication: Authenticating { get }
    var logInSwitcher: LogInSwitching { get }
}

class LogInDependencies: LogInDependenciesContaining {
    let authentication: Authenticating = Authentication()
    let logInSwitcher: LogInSwitching = LogInSwitcher()
}

protocol AuthenticatedDependenciesContaining {
    var token: String { get }
}

class AuthenticatedDependencies: AuthenticatedDependenciesContaining {
    let token: String

    init(token: String) {
        self.token = token
    }
}

protocol UserManagementDependenciesContaining {
    var userManager: UserManaging { get }
}

class UserManagementDependencies: UserManagementDependenciesContaining {
    let userManager: UserManaging

    init(userManager: UserManaging) {
        self.userManager = userManager
    }
}
