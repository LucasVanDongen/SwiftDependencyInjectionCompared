//
//  LogInComponent.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import NeedleFoundation
import SharedDependencies
import SwiftUI

protocol LogInDependency: Dependency {
    var logInSwitcher: LogInSwitching { get }
}

class LogInComponent: Component<LogInDependency> {
    var authentication: Authenticating {
        Authentication()
    }

    var logInView: some View {
        LogInView(
            authentication: authentication,
            logInSwitcher: dependency.logInSwitcher // This switcher "automagically" appears because of Needle's generated code
        )
    }
}
