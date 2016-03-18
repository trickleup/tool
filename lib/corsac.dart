library corsac;

import 'dart:async';
import 'dart:io';

import 'package:resource/resource.dart' as r;
import 'package:corsac_console/corsac_console.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

part 'src/commands.dart';

class CorsacTool extends Console {
  /// Internal constructor.
  CorsacTool._(Kernel kernel, String name, String description)
      : super(kernel, name, description);

  /// Creates an instance of `CorsacConsole`.
  static Future<CorsacTool> build() async {
    var kernel =
        await Kernel.build('local', {}, [new CorsacConsoleKernelModule()]);
    return new CorsacTool._(kernel, 'corsac', 'Corsac command line tool.');
  }
}

class CorsacConsoleKernelModule extends KernelModule {
  @override
  Map getServiceConfiguration(String environment) {
    return {
      "console.commands": DI.add([DI.get(InitCommand)]),
    };
  }
}
