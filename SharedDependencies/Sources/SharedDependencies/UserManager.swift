//
//  UserManager.swift
//
//
//  Created by Lucas van Dongen on 05/03/2024.
//

import Foundation

// ObservableObject is really here for EnvironmentObject
public protocol UserManaging: ObservableObject {
    var token: String { get }

    func update(user: String) async throws -> Bool
}

public class UserManager: ObservableObject, UserManaging {
    public let token: String

    public init(token: String) {
        self.token = token
    }

    public func update(user: String) async throws -> Bool {
        return true
    }
}
