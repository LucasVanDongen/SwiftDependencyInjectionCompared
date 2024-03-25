import SwiftUI

@MainActor
@main
struct SwiftDependenciesApp: App {
  let model = AppModel(
    state: .loggedOut(
      LoggedOutModel()
    )
  )

  var body: some Scene {
    WindowGroup {
      AppView(model: model)
    }
  }
}
