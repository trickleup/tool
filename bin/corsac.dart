#!/usr/bin/env dart
library corsac_tool.cli;

import 'package:corsac_tool/corsac_tool.dart';
import 'dart:async';
import 'dart:io';

Future main(List<String> args) async {
  var corsac = await CorsacTool.build();
  return corsac.run(args).then((_) {
    exit(0);
  });
}
