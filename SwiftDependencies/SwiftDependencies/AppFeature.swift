import Dependencies
import SharedDependencies
import SwiftUI

@MainActor
@Observable
class AppModel {
  @ObservationIgnored
  @Dependency(\.logInSwitcher) var logInSwitcher
  var state: State
  init(state: State) {
    self.state = state
    self.subscribe()
  }

  enum State {
    case authenticated(AuthenticatedModel)
    case loggedOut(LoggedOutModel)
  }

  func subscribe() {
    Task {
      for await token in logInSwitcher.tokenChannel {
        if token.isEmpty {
          state = .loggedOut(LoggedOutModel())
        } else {
          // Create the AuthenticatedModel in an altered environment where the \.userManager
          // and \.storyFetcher dependencies have been given a token. Without this step the app
          // will emit 🟣purple runtime warnings🟣 when the dependencies are accessed without being
          // overridden.
          state = .authenticated(
            withDependencies(from: self) {
              $0.userManager = UserManager(token: token)
              $0.storyFetcher = StoryFetcher(token: token)
            } operation: {
              AuthenticatedModel()
            }
          )
        }
      }
    }
  }
}

struct AppView: View {
  let model: AppModel

  var body: some View {
    switch model.state {
    case let .authenticated(model):
      AuthenticatedView(model: model)
    case let .loggedOut(model):
      LoggedOutView(model: model)
    }
  }
}
