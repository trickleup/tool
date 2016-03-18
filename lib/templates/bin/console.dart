#!/usr/bin/env dart
library __projectName__.cli;

import 'dart:async';
import 'package:__projectName__/__projectName__.dart';

Future main(List<String> args) async {
  var bootstrap = new Bootstrap();
  var console = await bootstrap.createConsole();
  return console.run(args);
}
