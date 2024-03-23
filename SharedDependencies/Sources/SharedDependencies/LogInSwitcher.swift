//
//  LogInSwitcher.swift
//
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import AsyncAlgorithms
import Foundation

public protocol LogInSwitching: Sendable {
    var tokenChannel: AsyncChannel<String> { get }

    func loggedIn(with token: String) async
    func loggedOut() async
}

public final class LogInSwitcher: LogInSwitching {
    public let tokenChannel = AsyncChannel<String>()

    public init() { }

    public func loggedIn(with token: String) async {
        await tokenChannel.send(token)
    }

    public func loggedOut() async {
        await tokenChannel.send("")
    }
}
