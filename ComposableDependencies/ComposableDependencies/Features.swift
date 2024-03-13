//
//  Features.swift
//  ComposableDependencies
//
//  Created by Lucas van Dongen on 06/03/2024.
//

import ComposableArchitecture
import SharedDependencies

struct Session: Equatable {
    let token: String
}


@Reducer(state: .equatable)
enum AppRootFeature {
    case authenticated(AuthenticatedFeature)
    case logIn(LogInFeature)

    public static var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .logIn(.authenticatedSuccessfully(token)):
                state = .authenticated(AuthenticatedFeature.State(token: token))
                return .none
            case .logIn:
                return .none // Ignore the rest
            case .authenticated:
                return .none // Ignore unless we would have log out functionality
            }
        }
        .ifCaseLet(\.logIn, action: \.logIn) {
            LogInFeature()
        }
        .ifCaseLet(\.authenticated, action: \.authenticated) {
            AuthenticatedFeature()
        }._printChanges()
    }
}

@Reducer
struct AuthenticatedFeature {
    @ObservableState
    struct State: Equatable {
        let token: String
    }

    enum Action {
        case showUser
        case showOrder
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showUser:
                return .none
            case .showOrder:
                return .none
            }
        }
    }
}

@Reducer
struct LogInFeature {
    @Dependency(\.authentication) var authentication

    @ObservableState
    struct State: Equatable { }

    enum Action {
        case logIn
        case authenticationError(Error)
        case authenticatedSuccessfully(token: String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .logIn:
                return .run { send in
                    do {
                        let token = try await authentication.authenticate()
                        await send(.authenticatedSuccessfully(token: token))
                    } catch let error {
                        await send(.authenticationError(error))
                    }
                }
            case let .authenticationError(error):
                print(error)
                return .none // Not handled ATM
            case .authenticatedSuccessfully:
                return .none // Only interesting for root feature
            }
        }
    }
}
