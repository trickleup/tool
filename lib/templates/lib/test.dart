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
library __projectName__.test;

import 'dart:async';
import 'dart:io';

import 'package:__projectName__/__projectName__.dart';
import 'package:corsac_bootstrap/test.dart' as base;
import 'package:corsac_kernel/corsac_kernel.dart';

export 'package:__projectName__/__projectName__.dart';
export 'package:corsac_bootstrap/test.dart';

part 'src/test/fixtures.dart';

/// Project's bootstrap instance for testing.
final Bootstrap bootstrap = new TestBootstrap();

class TestBootstrap extends Bootstrap {
  final List<KernelModule> testModules = [
    new base.TestKernelModule(),
    new FixturesKernelModule(fixtures)
  ];

  final List<KernelModule> integrationModules = [];

  @override
  Future<Kernel> buildKernel(
      {List<KernelModule> applicationModules: const [], String projectRoot}) {
    projectRoot = findProjectRoot(null);
    infrastructureModules.addAll(testModules);
    infrastructureModules.addAll(integrationModules);
    return super.buildKernel(
        applicationModules: applicationModules, projectRoot: projectRoot);
  }

  @override
  String findProjectRoot(String scriptPath) {
    var src = Uri.decodeFull(Platform.script.path);
    var regex =
        new RegExp('import \"file:\/\/([^\"]+)\" as test', multiLine: true);
    var rootSegments;
    Uri scriptUri;
    if (regex.hasMatch(src)) {
      // We are running via test package's dedicated binary.
      scriptUri = new Uri.file(regex.allMatches(src).first.group(1));
      rootSegments =
          scriptUri.pathSegments.takeWhile((seg) => seg != 'test').toList();
    } else {
      // We are running via normal command line execution bypassing test package.
      scriptUri = new Uri.file(Platform.script.path);
      rootSegments =
          scriptUri.pathSegments.takeWhile((seg) => seg != 'test').toList();
    }

    if (Platform.environment.containsKey('PROJECT_INTEGRATION_TESTS')) {
      rootSegments.addAll(['test', 'config', 'integration']);
    } else {
      rootSegments.addAll(['test', 'config', 'test']);
    }

    return scriptUri.replace(pathSegments: rootSegments).path +
        Platform.pathSeparator;
  }
}

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
