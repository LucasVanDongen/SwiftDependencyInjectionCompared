//
//  LogInSwitcher.swift
//
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import AsyncAlgorithms
import Foundation

// ObservableObject is really here for EnvironmentObject
public protocol LogInSwitching: ObservableObject, Sendable {
    var tokenChannel: AsyncChannel<String> { get }

    func loggedIn(with token: String) async
    func loggedOut() async
}

public final class LogInSwitcher: ObservableObject, LogInSwitching {
    public let tokenChannel = AsyncChannel<String>()

    public init() { }

    public func loggedIn(with token: String) async {
        await tokenChannel.send(token)
    }

    public func loggedOut() async {
        await tokenChannel.send("")
    }
}
