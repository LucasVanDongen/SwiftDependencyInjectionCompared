//
//  AuthenticatedFactory.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 23/03/2024.
//

import Foundation
import SharedDependencies

class AuthenticatedFactory: AuthenticatedDependenciesContaining {
    let logInSwitcher: LogInSwitching
    let userManager: UserManaging
    let storyFetcher: StoryFetching

    /// Everything that is needed to build this Factory needs to be passed forward, including dependencies already created in a parent node
    /// - Parameters:
    ///   - token: The key to unlock the `UserManager` and `StoryFetcher` implementations
    ///   - logInSwitcher: A dependency we need to pass forward from the root
    init(
        token: String,
        logInSwitcher: LogInSwitching // In Needle, all dependencies inherited from all nodes toward and including the root are handled by the `parent` Component
    ) {
        self.logInSwitcher = logInSwitcher
        userManager = UserManager(token: token)
        storyFetcher = StoryFetcher(token: token)
    }
}

// A separate extension for building the Views
// Ideal for keeping your Factories UI dependency free, or for supporting multiple platforms
extension AuthenticatedFactory {
    var userManagementView: UserManagementView {
        UserManagementView(userManager: userManager)
    }

    var storiesView: StoriesView {
        StoriesView(storyFetcher: storyFetcher)
    }
}

// Example implementation for AuthenticatedView using this Factory:
import SwiftUI

@MainActor
struct AuthenticatedFactoryView: View {
    let factory: AuthenticatedFactory

    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            // This View now knows nothing about how these Views are built
            factory.userManagementView
            factory.storiesView
            Button {
                isLoggingOut = true
            } label: {
                Text("Log Out")
            }.task(id: isLoggingOut, priority: .high) {
                guard isLoggingOut else {
                    return
                }

                defer {
                    isLoggingOut = false
                }

                await factory.logInSwitcher.loggedOut()
            }
        }
    }
}
