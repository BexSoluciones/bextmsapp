import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: rootBundle.loadString('pubspec.yaml'),
        builder: (context, snapshot) {
          var version = 'Unknown';
          if (snapshot.hasData) {
            var yaml = loadYaml(snapshot.data as String);
            version = yaml['version'];
          }
          return Text(version, style: const TextStyle(fontSize: 14));
        });
  }
}
