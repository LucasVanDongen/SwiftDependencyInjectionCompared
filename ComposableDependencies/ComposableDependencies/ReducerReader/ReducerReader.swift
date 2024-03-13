//
//  ReducerReader.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 13/03/2024.
//

import ComposableArchitecture

/// A reducer that builds a reducer from the current state and action.
public struct ReducerReader<State, Action, Reader: Reducer>: Reducer where Reader.State == State, Reader.Action == Action {
    @usableFromInline
    let reader: (State, Action) -> Reader

    /// Initializes a reducer that builds a reducer from the current state and action.
    ///
    /// - Parameter reader: A reducer builder that has access to the current state and action.
    @inlinable
    public init(@ReducerBuilder<State, Action> reader: @escaping (State, Action) -> Reader) {
        self.init(internal: reader)
    }

    @usableFromInline
    init(internal reader: @escaping (State, Action) -> Reader) {
        self.reader = reader
    }

    @inlinable
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        self.reader(state, action).reduce(into: &state, action: action)
    }
}
