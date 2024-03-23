//
//  Container.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import Combine
import SharedDependencies

protocol LogInDependenciesContaining {
    var authentication: Authenticating { get }
    var logInSwitcher: any LogInSwitching { get }
}

class LogInDependencies: LogInDependenciesContaining {
    let authentication: Authenticating = Authentication()
    let logInSwitcher: any LogInSwitching = LogInSwitcher()
}

protocol AuthenticatedDependenciesContaining {
    var logInSwitcher: any LogInSwitching { get }
    var userManager: any UserManaging { get }
    var storyFetcher: any StoryFetching { get }
}

class AuthenticatedDependencies: AuthenticatedDependenciesContaining {
    let userManager: any UserManaging
    let logInSwitcher: any LogInSwitching
    let storyFetcher: any StoryFetching

    init(
        token: String,
        logInSwitcher: any LogInSwitching
    ) {
        self.userManager = UserManager(token: token)
        self.logInSwitcher = logInSwitcher
        self.storyFetcher = StoryFetcher(token: token)
    }
}
