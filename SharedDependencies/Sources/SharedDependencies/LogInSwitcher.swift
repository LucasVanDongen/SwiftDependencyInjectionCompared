//
//  LogInSwitcher.swift
//
//
//  Created by Lucas van Dongen on 12/03/2024.
//

import Combine
import Foundation

// ObservableObject is really here for EnvironmentObject
public protocol LogInSwitching: ObservableObject {
    var tokenPublisher: PassthroughSubject<String, Never> { get }

    func loggedIn(with token: String)
}

public class LogInSwitcher: ObservableObject, LogInSwitching {
    public let tokenPublisher = PassthroughSubject<String, Never>()

    public init() { }

    public func loggedIn(with token: String) {
        tokenPublisher.send(token)
    }
}
