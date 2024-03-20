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

//protocol AuthenticatedDependenciesContaining {
//    var token: String { get }
//}
//
//class AuthenticatedDependencies: AuthenticatedDependenciesContaining {
//    let token: String
//
//    init(token: String) {
//        self.token = token
//    }
//}

protocol AuthenticatedDependenciesContaining {
    var userManager: any UserManaging { get }
    var logInSwitcher: any LogInSwitching { get }
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
