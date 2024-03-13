//
//  RootComponent.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import SharedDependencies
import NeedleFoundation
import SwiftUI

let rootComponent = RootComponent()

class RootComponent: BootstrapComponent {
    var logInComponent: LogInComponent { LogInComponent(parent: self) }

    var appView: some View { // requires SwiftUI. Move to UI layer, keep the rest of the Component in non-UI layer?
        AppView(
            viewModel: self.appViewModel,
            logInComponent: logInComponent,
            rootComponent: self // uhm circular reference?
        )
    }

    var appViewModel: AppViewModel {
        AppViewModel(logInSwitcher: logInComponent.logInSwitcher)
    }

    func authenticatedComponent(token: String) -> AuthenticatedComponent {
        AuthenticatedComponent(
            parent: self,
            token: token
        )
    }
}

extension RootComponent: LogInDependency {
    var logInSwitcher: LogInSwitching {
        shared { LogInSwitcher() }
    }
}
