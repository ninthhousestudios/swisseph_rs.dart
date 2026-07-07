import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    hierarchicalLoggingEnabled = true;
    final logger = Logger('swisseph_rs_build')
      ..level = Level.ALL
      ..onRecord.listen(
        (record) => print('${record.level.name}: ${record.message}'),
      );

    final rustDir = '${input.packageRoot.toFilePath()}rust';
    logger.info('Rust shim crate: $rustDir');

    final result = await Process.run('cargo', [
      'build',
      '--release',
      '--manifest-path',
      '$rustDir/Cargo.toml',
    ]);

    if (result.exitCode != 0) {
      logger.severe('cargo build failed:\n${result.stderr}');
      throw Exception('cargo build failed with exit code ${result.exitCode}');
    }
    logger.info('cargo build succeeded');

    final dylibName = input.config.code.targetOS.dylibFileName(
      'swisseph_rs_dart',
    );
    final dylibPath = '$rustDir/target/release/$dylibName';
    final dylibFile = File(dylibPath);
    if (!dylibFile.existsSync()) {
      throw Exception('Expected dylib not found: $dylibPath');
    }

    final outDir = input.outputDirectory;
    final outFile = File('${outDir.toFilePath()}$dylibName');
    dylibFile.copySync(outFile.path);
    logger.info('Copied $dylibPath -> ${outFile.path}');

    output.assets.code.add(
      CodeAsset(
        package: 'swisseph_rs',
        name: 'swisseph_rs.dart',
        linkMode: DynamicLoadingBundled(),
        file: outFile.uri,
      ),
    );

    output.dependencies.add(Directory(rustDir).uri);
  });
}
