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
          state = .authenticated(AuthenticatedModel(token: token))
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
