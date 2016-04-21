library __projectName__;

import 'package:corsac_bootstrap/corsac_bootstrap.dart' as base;
import 'package:corsac_console/corsac_console.dart';
import 'dart:async';

export 'domain.dart';

class Bootstrap extends base.Bootstrap {
  /// Name of environment variable defining project environment.
  final String environmentVarname = '__PROJECT_NAME___ENV';

  /// Filename of parameters file of this project.
  final String parametersFilename = '__projectName__.yaml';

  Bootstrap() {
    // Register your modules here.
    // infrastructureModules.add(new MyModule());
  }

  /// Creates console application for this project.
  ///
  /// To register custom commands with this app:
  /// * define a kernel module.
  /// * in `getServiceConfiguration` hook use `DI.add()` to add your command.
  ///   to container's `console.commands` entry.
  /// * add your module in `applicationModules` named argument of `buildKernel`
  ///   call.
  ///
  /// Example:
  ///
  ///     class MyCustomModule extends KernelModule {
  ///       @override
  ///       Map getServiceConfiguration(String environment) {
  ///         return {
  ///           'console.commands': DI.add([DI.get(YourCustomCommand)]),
  ///         };
  ///       }
  ///     }
  Future<Console> createConsole() async {
    var kernel = await buildKernel(applicationModules: []);
    return new Console(kernel, 'console', 'CLI console for __projectName__.');
  }
}
