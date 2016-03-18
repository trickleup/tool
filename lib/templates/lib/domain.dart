library __projectName__.domain;

import 'dart:async';

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_stateless/di.dart';

export 'package:corsac_stateless/corsac_stateless.dart';

part 'src/domain/blog.dart'; // Example domain entity (auto-generated).

class DomainKernelModule extends KernelModule {
  @override
  Map getServiceConfiguration(String environment) {
    return {
      IdentityMap: DI.get(ZoneLocalIdentityMap),
      ZoneLocalIdentityMap: DI.object()
        ..bindParameter('key', const Symbol('zoneLocalIdentityMapCache'))
    };
  }

  @override
  Future initialize(Kernel kernel) {
    kernel.container.addMiddleware(kernel.get(IdentityMapDIMiddleware));
    return new Future.value();
  }
}
