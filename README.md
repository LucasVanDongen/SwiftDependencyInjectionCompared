# Dependency Injection for Modern Swift Applications
## Dependency Injection for Modern Swift Applications and Comparing five different approaches towards Dependency Injection

![An AI generated hero image showing four syringes stuck into an apple, symbolifying the act of injecting dependencies on Apple platforms](images/injection_frameworks_compared.png)

This repo belongs to two articles I've written about dependency injection. I'm reviewing the following five principeles:

* [Compile-Time Safety](https://dependency_injection_swift_swiftui.php#compile-time-safety) - if it compiles, is it correct and crash-free?
* [Generational Safety](https://dependency_injection_swift_swiftui.php#generational-safety) - can we safely unlock dependencies later on?
* [Scalability](https://dependency_injection_swift_swiftui.php#scaling) - how hard is it to maintain or add features when the app grows?
* [Usability](https://dependency_injection_swift_swiftui.php#usability) - how easy is it to new team members and to add or maintain features?
* [Testability](https://dependency_injection_swift_swiftui.php#testability-and-previews) - can we easily mock our dependencies for tests and previews?

This repo holds simple but complete examples that highlight the different aspects of DI for each different approach. The following five frameworks or techniques for DI have been selected to give a complete overview of all different types of solutions that exist:

* [Manual Tree](https://github.com/LucasVanDongen/SwiftDependencyInjectionCompared/tree/main/PassedDependencies) - Pass all dependencies manually
* [EnvironmentObject](https://github.com/LucasVanDongen/SwiftDependencyInjectionCompared/tree/main/EnvironmentDependencies) - Using SwiftUI's built in storage
* [Factory](https://github.com/LucasVanDongen/SwiftDependencyInjectionCompared/tree/main/FactoryDependencies) - A simple statically declared container approach
* [Needle](https://github.com/LucasVanDongen/SwiftDependencyInjectionCompared/tree/main/NeedleDependencies) - Uber's solution to boilerplate-heavy manual solutions
* [Composable Architecture](https://https://github.com/LucasVanDongen/SwiftDependencyInjectionCompared/tree/main/ComposableDependencies) - How does TCA's solution compare?

Read the first article ["Managing Dependencies in the Age of SwiftUI" here](dependency_injection_swift_swiftui.php), and the second article ["Comparing five different approaches towards Dependency Injection" here](dependency_injection_swift_swiftui.php).
