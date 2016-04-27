library __projectName__.infrastructure;

import 'package:corsac_kernel/corsac_kernel.dart';

/// Generic module to put anything related to infrastructure, like
/// service configuration for databases or other external resources.
class InfrastructureKernelModule extends KernelModule {
  @override
  Map getServiceConfiguration(String environment) {
    return {};
  }
}
