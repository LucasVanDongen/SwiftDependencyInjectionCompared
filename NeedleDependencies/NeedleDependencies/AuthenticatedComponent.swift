//
//  AuthenticatedComponent.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import NeedleFoundation
import SharedDependencies
import SwiftUI

protocol AuthenticatedDependency: Dependency {
    var logInSwitcher: any LogInSwitching { get }
}

class AuthenticatedComponent: Component<AuthenticatedDependency> {
    var userManager: any UserManaging {
        return shared { UserManager(token: token) }
    }

    var storyFetcher: any StoryFetching {
        return shared { StoryFetcher(token: token) }
    }

    private let token: String

    init(
        parent: Scope,
        token: String
    ) {
        self.token = token
        super.init(parent: parent)
    }
}

@MainActor
protocol AuthenticatedViewBuilding {
    var authenticatedView: AuthenticatedView { get }
    var storiesView: StoriesView { get }
    var userManagementView: UserManagementView { get }
}

extension AuthenticatedComponent: AuthenticatedViewBuilding {
    var authenticatedView: AuthenticatedView {
        AuthenticatedView(
            logInSwitcher: dependency.logInSwitcher,
            component: self
        )
    }

    var storiesView: StoriesView {
        StoriesView(storyFetcher: storyFetcher)
    }

    var userManagementView: UserManagementView {
        UserManagementView(userManager: userManager)
    }
}
