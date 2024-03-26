import Dependencies
import SharedDependencies
import SwiftUI

@MainActor
@Observable
class AuthenticatedModel {
  @ObservationIgnored
  @Dependency(\.logInSwitcher) var logInSwitcher

  var isLoggingOut = false
  let stories: StoriesModel
  let userManagement: UserManagementModel

  init(token: String) {
    stories = StoriesModel(token: token)
    userManagement = UserManagementModel(token: token)
  }

  func logoutButtonTapped() async {
    isLoggingOut = true
    defer { isLoggingOut = false }

    await logInSwitcher.loggedOut()
  }
}

struct AuthenticatedView: View {
  let model: AuthenticatedModel

  var body: some View {
    Form {
      UserManagementView(model: model.userManagement)
      StoriesView(model: model.stories)

      Button("Log out") {
        Task { await model.logoutButtonTapped() }
      }
      .disabled(model.isLoggingOut)
    }
  }
}

@MainActor
@Observable
class UserManagementModel {
  @ObservationIgnored
  @Dependency var userManager: any UserManaging

  init(token: String) {
    // In order to access the 'userManager` dependency we must supply proof that the user is
    // authenaticated by passing the token to the subscript key path.
    self._userManager = Dependency(\.[userManagerForToken: token])
    self.state = .loaded
  }

  var state = State.loaded

  enum State {
    case loaded
    case updating
    case failed(reason: String)
    case updated
  }

  func updateUserButtonTapped() async {
    state = .updating
    do {
      _ = try await userManager.update(user: "")
      state = .updated
    } catch {
      state = .failed(reason: "Something went wrong")
    }
  }
}

struct UserManagementView: View {
  let model: UserManagementModel

  var body: some View {
    Section {
      Text("You are logged in with token \(model.userManager.token)")
      switch model.state {
      case .loaded:
        Button("Update user") {
          Task { await model.updateUserButtonTapped() }
        }
      case .updating:
        HStack { Text("Updating User..."); ProgressView() }
      case let .failed(reason):
        Text("Failed updating User:\n\(reason)")
      case .updated:
        Text("You have updated your user successfully")
      }
    } header: {
      Text("User management")
    }
  }
}

@MainActor
@Observable
class StoriesModel {
  @ObservationIgnored
  @Dependency private var storyFetcher: any StoryFetching

  init(token: String) {
    // In order to access the 'storyFetcher` dependency we must supply proof that the user is
    // authenaticated by passing the token to the subscript key path.
    self._storyFetcher = Dependency(\.[storyFetcherForToken: token])
    self.state = state
  }

  var state = State.fetching

  enum State {
    case fetching
    case failed(reason: String)
    case fetched(stories: [Story])
  }

  func onFetch() async {
    state = .fetching
    do {
      state = .fetched(stories: try await storyFetcher.fetchStories())
    } catch let error {
      state = .failed(reason: error.localizedDescription)
    }
  }
}

struct StoriesView: View {
  let model: StoriesModel

  var body: some View {
    Section {
      switch model.state {
      case .fetching:
        HStack { Text("Fetching stories..."); ProgressView() }
          .task { await model.onFetch() }
      case let .failed(reason):
        Text("Failed fetching stories:\n\(reason)")
      case let .fetched(stories):
        List {
          ForEach(stories, id: \.name) { story in
            Text("Author: \(story.author)\nName: \(story.name)")
          }
        }
      }
    } header: {
      Text("Stories")
    }
  }
}
