/// Library with test utilities for __projectName__.
///
/// There are two test environments: "test" and "integration". The difference
/// between those is:
///
/// * The "test" environment (default) is intended to give you fast "feedback loop"
///   which means execution of tests should be relatively fast so that you can
///   constantly run them during development. To achieve that we get rid of all
///   external dependencies of our application (databases and APIs, for example)
///   and replace them with fast "in-memory" implementations and/or stubs.
/// * The "integration" environment is intended to test "real life" interactions
///   between your application and it's external dependencies, mostly databases
///   queueing systems and such. Any external APIs may still be replaced by stubs
///   though this can differ from case to case. You are free to define your
///   preference in the [TestKernelModule] provided by this library.
///
/// When you run tests with `pub run test` they execute in the "test" environment
/// by default.
library __projectName__.testing;

import 'dart:async';

import 'package:__projectName__/__projectName__.dart';
import 'package:corsac_dal/di.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

export 'package:__projectName__/__projectName__.dart';
export 'package:corsac_bootstrap/testing.dart';

part 'src/testing/fixtures.dart';

/// Project's bootstrap instance for testing.
final Bootstrap bootstrap = new TestBootstrap();

class TestBootstrap extends Bootstrap {
  TestBootstrap() : super() {
    logLevel = Level.OFF;
    modules.add(new TestKernelModule());
    modules.add(new FixturesKernelModule(fixtures));
  }
}

/// Kernel module for test environment.
/// Adds container middleware which replaces all repositories with
/// in-memory implementations.
class TestKernelModule extends KernelModule {
  @override
  Future initialize(Kernel kernel) {
    if (kernel.environment == 'test') {
      // Register in-memory implementations for repository layer.
      kernel.container.addMiddleware(new InMemoryRepositoryDIMiddleware());
    }
    return new Future.value();
  }
}

/// Kernel module which loads fixtures to be used in tests.
class FixturesKernelModule extends KernelModule {
  final Iterable<Object> fixtures;

  FixturesKernelModule(this.fixtures);

  Future initialize(Kernel kernel) {
    loadFixtures(kernel);
    return new Future.value();
  }

  Future loadFixtures(Kernel kernel) {
    return kernel.execute((Repository<Post> postRepository) {
      for (var obj in fixtures) {
        postRepository.put(obj);
      }
    });
  }
}
