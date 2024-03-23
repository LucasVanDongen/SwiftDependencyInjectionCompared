//
//  EnvironmentSetup.swift
//  EnvironmentDependencies
//
//  Created by Lucas van Dongen on 23/03/2024.
//

import Foundation
import SharedDependencies
import SwiftUI

private struct AuthenticationEnvironmentKey: EnvironmentKey {
    static let defaultValue: Authenticating = Authentication()
}

private struct UserManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserManaging = PlaceholderUserManager()
}

private struct LogInSwitcherEnvironmentKey: EnvironmentKey {
    static let defaultValue: LogInSwitching = LogInSwitcher()
}

extension EnvironmentValues {
    var authentication: Authenticating {
        get { self[AuthenticationEnvironmentKey.self] }
        set { self[AuthenticationEnvironmentKey.self] = newValue }
    }
    var userManager: UserManaging {
        get { self[UserManagerEnvironmentKey.self] }
        set { self[UserManagerEnvironmentKey.self] = newValue }
    }
    var logInSwitcher: LogInSwitching {
        get { self[LogInSwitcherEnvironmentKey.self] }
        set { self[LogInSwitcherEnvironmentKey.self] = newValue }
    }
}
