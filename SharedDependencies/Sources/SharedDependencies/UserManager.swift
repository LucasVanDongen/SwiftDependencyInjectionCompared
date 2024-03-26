//
//  UserManager.swift
//
//
//  Created by Lucas van Dongen on 05/03/2024.
//

import Foundation

// ObservableObject is really here for EnvironmentObject
public protocol UserManaging: Sendable {
    var token: String { get set }

    func update(user: String) async throws -> Bool
}

public struct UserManager: UserManaging {
    public var token: String

    public init(token: String) {
        self.token = token
    }

    public func update(user: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(2))
        return true
    }
}
