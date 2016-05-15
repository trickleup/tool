part of corsac_tool;

class InitCommand extends Command {
  @override
  final String description = "Initialize Corsac project in current directory.";

  @override
  final String name = 'init';

  InitCommand() : super() {}

  List<String> _templates = [
    'pubspec.yaml',
    'dotenv',
    '.gitignore',
    'bin/console.dart',
    'lib/__projectName__.dart',
    'lib/domain.dart',
    'lib/infrastructure.dart',
    'lib/testing.dart',
    'lib/src/domain/blog.dart',
    'lib/src/testing/fixtures.dart',
    'test/domain/blog_test.dart',
  ];

  @override
  run() async {
    stdout.write('Enter project name (ex: my_blog): ');
    var projectName = stdin.readLineSync();
    if (projectName.isEmpty) {
      throw new ArgumentError('Must provide project name.');
    }

    print('Initializing project ${projectName} in ${Directory.current.path}.');

    if (Directory.current.listSync().isNotEmpty) {
      print('Current directory is not empty. Do you wish to continue? [Y/n]: ');
      var answer = stdin.readLineSync();
      if (['n', 'no'].contains(answer.toLowerCase().trim())) {
        print('Aborting');
        exit(0);
      }
    }

    for (var templateName in _templates) {
      var res = new r.Resource('package:corsac_tool/templates/${templateName}');
      var content = await res.readAsString();
      var filename = templateName
          .replaceAll('__projectName__', projectName)
          .replaceAll('dotenv', '.env');
      ensureDirectoryExists(filename);
      content = content.replaceAll('__projectName__', projectName);
      var fileSegments = Directory.current.uri.pathSegments.toList();
      fileSegments.addAll(filename.split('/'));

      var uri = Directory.current.uri.replace(pathSegments: fileSegments);
      var file = new File(uri.path);
      print('Creating ${file.path}.');
      file.writeAsStringSync(content);
    }

    return new Future.value();
  }

  void ensureDirectoryExists(String filename) {
    var segments = filename.split('/');
    segments.removeLast();
    var currentSegments = Directory.current.uri.pathSegments.toList();
    currentSegments.addAll(segments);
    var dir = new Directory(
        Directory.current.uri.replace(pathSegments: currentSegments).path);
    dir.createSync(recursive: true);
  }
}

class TestCommand extends Command {
  @override
  final String description = "Run tests.";

  @override
  final String name = 'test';

  TestCommand() : super() {
    argParser.addFlag('integration',
        abbr: 'i',
        help: 'Run tests in integration environment',
        negatable: false);
  }

  @override
  Future run() async {
    var pubRunArgs = ['run', 'test'];
    pubRunArgs.addAll(argResults.rest);
    var env = {};
    if (argResults['integration'] == true) {
      env['CORSAC_ENV'] = 'integration';
    }
    print('Running: pub ' + pubRunArgs.join(' '));
    return Process.start('pub', pubRunArgs, environment: env).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);
      return process.exitCode;
    }).then((code) {
      exitCode = code;
    });
  }
}

/// Builds project artifact for distribution.
///
/// This copies all project sources and dependencies to `destination` folder and
/// makes sure `.packages` has proper paths to all deps.
class BuildCommand extends Command {
  @override
  final String description = "Build project artifact.";

  @override
  final String name = 'build';

  BuildCommand() : super() {
    argParser.addOption('destination',
        abbr: 'd',
        help: 'Destination folder for the artifact (relative to project root)',
        defaultsTo: ['artifact', 'dist'].join(Platform.pathSeparator));
  }

  @override
  Future run() async {
    var destination =
        _path([Directory.current.path, argResults['destination']]);
    print('Destination folder is `${destination}`');
    var destinationDir = new Directory(destination);
    if (destinationDir.existsSync()) {
      destinationDir.deleteSync(recursive: true);
    }
    destinationDir.createSync(recursive: true);

    // Copy everything from lib (excluding testing)
    print('Copying project sources (lib/ folder)...');
    var libDir = [Directory.current.path, 'lib'].join(Platform.pathSeparator);
    var destLibDir = [destination, 'lib'].join(Platform.pathSeparator);
    _runProcess('cp', ['-r', libDir, destLibDir]);
    var testingLibFile = new File(_path([destLibDir, 'testing.dart']));
    if (testingLibFile.existsSync()) {
      testingLibFile.deleteSync();
    }
    var testingLibDir = new Directory(_path([destLibDir, 'src', 'testing']));
    if (testingLibDir.existsSync()) {
      testingLibDir.deleteSync(recursive: true);
    }

    // Copy all binaries
    print('Copying project binaries (bin/ folder)...');
    var binDir = _path([Directory.current.path, 'bin']);
    var destBinDir = _path([destination, 'bin']);
    if (!new Directory(destBinDir).existsSync()) {
      new Directory(destBinDir).createSync(recursive: true);
    }

    for (var entry in new Directory(binDir).listSync()) {
      if (entry.statSync().type == FileSystemEntityType.FILE) {
        _runProcess('cp', [entry.path, destBinDir + Platform.pathSeparator]);
      }
    }

    // Copy package spec file and adjust paths to be relative.
    print('Copying dependencies (packages)...');
    var packages = loadPackageSpec();
    var lines = [];
    for (var packageName in packages.keys) {
      var destPackageDir = _path([destination, 'packages', packageName]);
      var sourcePath = "${packages[packageName].path}.";
      Uri newPath = new Uri.file(_path(['..', 'lib']));
      if (sourcePath != 'lib/') {
        new Directory(destPackageDir).createSync(recursive: true);
        _runProcess('cp', ['-r', sourcePath, destPackageDir]);
        newPath = new Uri.file(_path(['..', 'packages', packageName]));
      }
      packages[packageName] = newPath;
      lines.add('${packageName}:${newPath.toFilePath()}');
    }

    print('Writing adjusted `bin/.packages`...');
    var newPackageSpec = new File(_path([destBinDir, '.packages']));
    var sink = newPackageSpec.openWrite();
    sink.writeAll(lines, '\n');
    await sink.flush();
    await sink.close();

    print('Done.');
  }
}

Map<String, Uri> loadPackageSpec() {
  var file = new File(_path([Directory.current.path, '.packages']));
  List<String> lines =
      file.readAsStringSync().split('\n').where((_) => !_.startsWith('#'));
  var result = {};
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    var pos = line.indexOf(':');
    var packageName = line.substring(0, pos);
    result[packageName] = Uri.parse(line.substring(pos + 1));
  }

  return result;
}

String _path(Iterable<String> segments) =>
    segments.join(Platform.pathSeparator);

void _runProcess(String executable, Iterable<String> arguments) {
  var result = Process.runSync(executable, arguments);
  if (result.exitCode != 0) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}
