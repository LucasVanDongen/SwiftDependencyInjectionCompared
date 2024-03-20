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
//                .dependency(\.userManager, UserManager(token: token)
//                .dependency(\.storyFetcher, .StoryFetcher(token: token)
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
        case logOut
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOut:
                return .none
            }
        }
    }
}

@Reducer
struct LogInFeature {
    @Dependency(\.authentication) var authentication

    @ObservableState
    enum State: Equatable {
        case waiting
        case authenticating
    }

    enum Action {
        case logIn
        case authenticationError(Error)
        case authenticatedSuccessfully(token: String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .logIn:
                state = .authenticating
                return .run { send in
                    do {
                        let token = try await authentication.authenticate()
                        await send(.authenticatedSuccessfully(token: token))
                    } catch let error {
                        await send(.authenticationError(error))
                    }
                }
            case .authenticationError:
                return .none // Not handled ATM
            case .authenticatedSuccessfully:
                return .none // Only interesting for root feature
            }
        }
    }
}

@Reducer
struct StoriesFeature {
    @Dependency(\.storyFetcher) var storyFetcher

    @ObservableState
    enum State: Equatable {
        case loading
        case failed(reason: String)
        case loaded(stories: [Story])
    }

    enum Action {
        case startLoading
        case loaded(stories: [Story])
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startLoading:
                return .run { send in
                    do {
                        let stories = try await storyFetcher.fetchStories()
                        await send(.loaded(stories: stories))
                    } catch {
                        // We're ignoring error handling for now
                    }
                }
            case let .loaded(stories):
                state = .loaded(stories: stories)
                return .none
            }
        }
    }
}

@Reducer
struct UserManagementFeature {
    @Dependency(\.userManager) var userManager

    @ObservableState
    enum State: Equatable {
        case loaded
        case updating
        case failed(reason: String)
        case updated
    }

    enum Action {
        case update
        case failed(reason: String)
        case updated
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .update:
                state = .updating

                return .run { send in
                    do {
                        _ = try await userManager.update(user: "")
                        await send(.updated)
                    } catch {
                        // Ignore for now
                    }
                }
            case let .failed(reason):
                state = .failed(reason: reason)
                return .none
            case .updated:
                state = .updated
                return .none
            }
        }
    }
}
