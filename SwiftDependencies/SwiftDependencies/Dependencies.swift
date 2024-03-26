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

struct TestUserManager: UserManaging {
  var token = "WR0NG_T4K3N"

  func update(user: String) async throws -> Bool {
    XCTFail("UserManaging.update(user:)")
    return false
  }
}

private enum UserManagerKey: TestDependencyKey {
  static let testValue: any UserManaging = TestUserManager()
}

extension DependencyValues {
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
  var userManager: any UserManaging {
    get { self[UserManagerKey.self] }
    set { self[UserManagerKey.self] = newValue }
  }
}

final class TestStoryFetcher: StoryFetching {
  func fetchStories() async throws -> [Story] {
    XCTFail("StoryFetching.fetchStories")
    return []
  }
}

private enum StoryFetcherKey: TestDependencyKey {
  static let testValue: any StoryFetching = TestStoryFetcher()
}

extension DependencyValues {
  var storyFetcher: any StoryFetching {
    get { self[StoryFetcherKey.self] }
    set { self[StoryFetcherKey.self] = newValue }
  }
}
