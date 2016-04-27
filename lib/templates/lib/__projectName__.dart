library __projectName__;

import 'package:__projectName__/infrastructure.dart';
import 'package:corsac_bootstrap/corsac_bootstrap.dart';

export 'package:__projectName__/domain.dart';
export 'package:__projectName__/infrastructure.dart';
export 'package:logging/logging.dart';

/// Bootstrap class for __projectName__.
///
/// This takes care of project's assempbly process.
class Bootstrap extends CorsacBootstrap {
  Bootstrap() {
    projectName = '__projectName__';
    logLevel = Level.INFO;

    // Register your modules here:
    modules.add(new InfrastructureKernelModule());
  }
}
