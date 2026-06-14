import 'package:embed_annotation/embed_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

part 'pubspec.g.dart';

typedef DpkPubspec = ({String version});

@EmbedLiteral('/pubspec.yaml')
const DpkPubspec pubspec = _$pubspec;

Version get dpkVersion => Version.parse(pubspec.version);
