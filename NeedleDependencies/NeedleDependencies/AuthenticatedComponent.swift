//
//  AuthenticatedComponent.swift
//  NeedleDependencies
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import NeedleFoundation
import SharedDependencies
import SwiftUI

//protocol AuthenticatedDependency: Dependency {
//    var userManager: UserManaging { get }
//}

class AuthenticatedComponent: Component<EmptyDependency> {
    var userManager: UserManaging {
        return shared { UserManager(token: token) }
    }

    var authenticatedView: some View {
        AuthenticatedView(userManager: userManager)
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
