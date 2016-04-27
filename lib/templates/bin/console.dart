#!/usr/bin/env dart
library __projectName__.cli;

import 'dart:async';
import 'dart:io';

import 'package:__projectName__/__projectName__.dart';

Future main(List<String> args) async {
  var projectRoot = Platform.script.path.replaceFirst('bin/console.dart', '');
  var bootstrap = new Bootstrap();
  var console = await bootstrap.createConsole(projectRoot: projectRoot);
  return console.run(args);
}
