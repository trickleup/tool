/// Command-line tool for Corsac projects.
library corsac_tool;

import 'dart:async';
import 'dart:io';

import 'package:resource/resource.dart' as r;
import 'package:corsac_console/corsac_console.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

part 'src/commands.dart';

class CorsacTool extends Console {
  /// Internal constructor.
  CorsacTool._(Kernel kernel, String name, String description)
      : super(kernel, name, description) {
    commandRunner.addCommand(kernel.get(InitCommand));
    commandRunner.addCommand(kernel.get(TestCommand));
  }

  /// Creates an instance of `CorsacConsole`.
  static Future<CorsacTool> build() async {
    var kernel = await Kernel.build('local', {}, []);
    return new CorsacTool._(kernel, 'corsac', 'Corsac command line tool.');
  }
}
