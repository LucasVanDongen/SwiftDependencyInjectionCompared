

import NeedleFoundation
import SharedDependencies
import SwiftUI

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Traversal Helpers

private func parent1(_ component: NeedleFoundation.Scope) -> NeedleFoundation.Scope {
    return component.parent
}

// MARK: - Providers

#if !NEEDLE_DYNAMIC

private class AuthenticatedDependencycda53ef9a0d1fafe1614Provider: AuthenticatedDependency {
    var logInSwitcher: any LogInSwitching {
        return rootComponent.logInSwitcher
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->AuthenticatedComponent
private func factory31f7272d9f1e1bb4556eb3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return AuthenticatedDependencycda53ef9a0d1fafe1614Provider(rootComponent: parent1(component) as! RootComponent)
}
private class LogInDependency59c56af202a7286b1d4fProvider: LogInDependency {
    var logInSwitcher: any LogInSwitching {
        return rootComponent.logInSwitcher
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->LogInComponent
private func factory722f9ff168b373921da5b3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return LogInDependency59c56af202a7286b1d4fProvider(rootComponent: parent1(component) as! RootComponent)
}

#else
extension AuthenticatedComponent: Registration {
    public func registerItems() {
        keyPathToName[\AuthenticatedDependency.logInSwitcher] = "logInSwitcher-any LogInSwitching"
    }
}
extension RootComponent: Registration {
    public func registerItems() {


    }
}
extension LogInComponent: Registration {
    public func registerItems() {
        keyPathToName[\LogInDependency.logInSwitcher] = "logInSwitcher-any LogInSwitching"
    }
}


#endif

private func factoryEmptyDependencyProvider(_ component: NeedleFoundation.Scope) -> AnyObject {
    return EmptyDependencyProvider(component: component)
}

// MARK: - Registration
private func registerProviderFactory(_ componentPath: String, _ factory: @escaping (NeedleFoundation.Scope) -> AnyObject) {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: componentPath, factory)
}

#if !NEEDLE_DYNAMIC

@inline(never) private func register1() {
    registerProviderFactory("^->RootComponent->AuthenticatedComponent", factory31f7272d9f1e1bb4556eb3a8f24c1d289f2c0f2e)
    registerProviderFactory("^->RootComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootComponent->LogInComponent", factory722f9ff168b373921da5b3a8f24c1d289f2c0f2e)
}
#endif

public func registerProviderFactories() {
#if !NEEDLE_DYNAMIC
    register1()
#endif
}
