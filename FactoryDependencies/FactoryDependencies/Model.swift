//
//  Model.swift
//  PassedDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import Foundation

enum AppState {
    case loggedOut
    case authenticated(token: String)
}
