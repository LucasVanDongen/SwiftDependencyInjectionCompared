//
//  Placeholders.swift
//
//
//  Created by Lucas van Dongen on 22/03/2024.
//

import Foundation

// This implementation is used to prevent a `nil` value for this dependency while the user is not authenticated yet
public final class PlaceholderUserManager: UserManaging {
    public let token = "WR0NG_T0K3N"

    public init() { }

    public func update(user: String) async throws -> Bool {
        return false
    }
}

public final class PlaceholderStoryFetcher: StoryFetching {
    public init() { }

    // You have an issue if this function would actually be called
    public func fetchStories() async throws -> [Story] {
        return []
    }
}
