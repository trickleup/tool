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
    return Process.start('pub', pubRunArgs, environment: env).then((process) {
      process.stdout.pipe(stdout);
      return process.exitCode;
    }).then((code) {
      exitCode = code;
    });
  }
}
