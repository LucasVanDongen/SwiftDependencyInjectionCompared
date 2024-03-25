import Dependencies
import SwiftUI

@MainActor
@Observable
class LoggedOutModel {
  @ObservationIgnored
  @Dependency(\.authentication) var authentication
  @ObservationIgnored
  @Dependency(\.logInSwitcher) var logInSwitcher

  var isAuthenticating = false
  func loginButtonTapped() async {
    isAuthenticating = true
    defer { isAuthenticating = false }
    do {
      let token = try await authentication.authenticate()
      await logInSwitcher.loggedIn(with: token)
    } catch {
      // TODO: Handle this
    }
  }
}

struct LoggedOutView: View {
  let model: LoggedOutModel

  var body: some View {
    Form {
      if model.isAuthenticating {
        HStack { Text("Authenticating..."); ProgressView() }
      } else {
        Text("You are logged out")
      }
      Button("Log in") {
        Task { await model.loginButtonTapped() }
      }
      .disabled(model.isAuthenticating)
    }
  }
}
