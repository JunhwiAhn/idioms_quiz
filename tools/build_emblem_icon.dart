// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:image/image.dart' as image;

void main() {
  final source = File('assets/images/rank_spain_emblem.png');
  final bytes = source.readAsBytesSync();
  final emblem = image.decodePng(bytes);
  if (emblem == null) {
    throw StateError('Could not decode ${source.path}');
  }

  final icon = image.copyResize(
    emblem,
    width: 1024,
    height: 1024,
    interpolation: image.Interpolation.cubic,
  );

  final encoded = image.encodePng(icon, level: 9);
  File('assets/images/app_icon.png').writeAsBytesSync(encoded);
  File('assets/images/favicon.png').writeAsBytesSync(encoded);
}
