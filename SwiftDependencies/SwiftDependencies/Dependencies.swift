import Dependencies
import SharedDependencies

private enum LogInSwitchingKey: DependencyKey {
  static let liveValue: any LogInSwitching = LogInSwitcher()
}
extension DependencyValues {
  var logInSwitcher: any LogInSwitching {
    get { self[LogInSwitchingKey.self] }
    set { self[LogInSwitchingKey.self] = newValue }
  }
}

private enum AuthenticationKey: DependencyKey {
  static let liveValue: any Authenticating = Authentication()
}

extension DependencyValues {
  var authentication: Authenticating {
    get { self[AuthenticationKey.self] }
    set { self[AuthenticationKey.self] = newValue }
  }
}

extension DependencyValues {
  private enum UserManagerKey: DependencyKey {
    static let liveValue: any UserManaging = UserManager(token: "invalid-token")
  }
  subscript(userManagerForToken token: String) -> any UserManaging {
    get {
      var manager = self[UserManagerKey.self]
      manager.token = token
      return manager
    }
    set {
      var newValue = newValue
      newValue.token = token
      self[UserManagerKey.self] = newValue
    }
  }
}

extension DependencyValues {
  private enum StoryFetcherKey: DependencyKey {
    static let liveValue: any StoryFetching = StoryFetcher(token: "invalid-token")
  }
  subscript(storyFetcherForToken token: String) -> any StoryFetching {
    get {
      var manager = self[StoryFetcherKey.self]
      manager.token = token
      return manager
    }
    set {
      var newValue = newValue
      newValue.token = token
      self[StoryFetcherKey.self] = newValue
    }
  }
}
