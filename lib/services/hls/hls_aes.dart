import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// AES-128 attributes from an HLS media playlist.
class HlsAes128 {
  const HlsAes128({
    required this.keyUrl,
    this.iv,
    this.mediaSequence = 0,
  });

  final String keyUrl;
  final Uint8List? iv;
  final int mediaSequence;
}

/// Parses `#EXT-X-KEY:METHOD=AES-128` and `#EXT-X-MEDIA-SEQUENCE`.
HlsAes128? parseHlsAes128(String playlistBody, String playlistUrl) {
  final playlistUri = Uri.parse(playlistUrl);
  var mediaSequence = 0;
  HlsAes128? found;
  for (final raw in playlistBody.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('#EXT-X-MEDIA-SEQUENCE')) {
      final value = int.tryParse(line.substring(line.indexOf(':') + 1).trim());
      if (value != null) mediaSequence = value;
      continue;
    }
    if (!line.contains('#EXT-X-KEY')) continue;
    if (!line.toUpperCase().contains('METHOD=AES-128')) continue;
    if (line.toUpperCase().contains('SAMPLE-AES')) continue;
    final uriMatch = RegExp(
      r'URI="([^"]+)"',
      caseSensitive: false,
    ).firstMatch(line);
    if (uriMatch == null) continue;
    final ivMatch = RegExp(
      r'IV=0x([A-Fa-f0-9]+)',
      caseSensitive: false,
    ).firstMatch(line);
    Uint8List? iv;
    if (ivMatch != null) {
      try {
        iv = Uint8List.fromList(hex.decode(ivMatch.group(1)!));
      } catch (_) {
        iv = null;
      }
    }
    found = HlsAes128(
      keyUrl: playlistUri.resolve(uriMatch.group(1)!).toString(),
      iv: iv,
      mediaSequence: mediaSequence,
    );
  }
  if (found == null) return null;
  return HlsAes128(
    keyUrl: found.keyUrl,
    iv: found.iv,
    mediaSequence: mediaSequence,
  );
}

/// HLS AES-128-CBC. [sequence] is used as IV when [iv] is omitted.
Uint8List decryptHlsAes128(
  Uint8List encrypted,
  Uint8List key, {
  Uint8List? iv,
  int sequence = 0,
}) {
  var actualIv = iv;
  if (actualIv == null) {
    actualIv = Uint8List(16);
    ByteData.view(actualIv.buffer).setUint64(8, sequence);
  }
  final encrypter = encrypt.Encrypter(
    encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
  );
  return Uint8List.fromList(
    encrypter.decryptBytes(
      encrypt.Encrypted(encrypted),
      iv: encrypt.IV(actualIv),
    ),
  );
}
