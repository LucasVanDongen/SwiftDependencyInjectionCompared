//
//  RootComponent.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import SharedDependencies
import NeedleFoundation
import SwiftUI

class RootComponent: BootstrapComponent {
    var logInComponent: LogInComponent { LogInComponent(parent: self) }

    func authenticatedComponent(token: String) -> AuthenticatedComponent {
        AuthenticatedComponent(
            parent: self,
            token: token
        )
    }
}

extension RootComponent: LogInDependency {
    var logInSwitcher: any LogInSwitching {
        shared { LogInSwitcher() }
    }
}

protocol AppViewBuilding {
    @MainActor
    var appView: AppView { get }

    @MainActor
    var appViewModel: AppViewModel { get }
}

extension RootComponent: AppViewBuilding {
    @MainActor
    var appView: AppView {
        AppView(
            viewModel: self.appViewModel,
            rootComponent: self,
            logInComponent: logInComponent
        )
    }

    @MainActor
    var appViewModel: AppViewModel {
        AppViewModel(logInSwitcher: logInComponent.logInSwitcher)
    }
}
