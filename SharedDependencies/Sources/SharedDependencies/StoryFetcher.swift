//
//  StoryFetcher.swift
//
//
//  Created by Lucas van Dongen on 19/03/2024.
//

import Foundation

public struct Story: Sendable, Equatable {
    public let author: String
    public let name: String
}

public protocol StoryFetching: Sendable, Observable {
    var token: String { get set }
    func fetchStories() async throws -> [Story]
}

@Observable
public final class StoryFetcher: StoryFetching {
    public var token: String

    public init(token: String) {
        self.token = token
    }

    public func fetchStories() async throws -> [Story] {
        try await Task.sleep(for: .seconds(2))
        return [
            Story(author: "Frank Herbert", name: "Dune"),
            Story(author: "Larry Niven", name: "Ringworld"),
            Story(author: "Vernor Vinge", name: "A Fire Upon the Deep")
        ]
    }
}
