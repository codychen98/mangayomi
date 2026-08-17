import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/services/hls/hls_png_strip_proxy.dart';

Uint8List _tsPair() {
  final first = List<int>.filled(188, 0);
  first[0] = 0x47;
  final second = List<int>.filled(188, 0);
  second[0] = 0x47;
  return Uint8List.fromList([...first, ...second]);
}

Uint8List _jpegPrefix({bool withEoi = true}) {
  return Uint8List.fromList([
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
    0x49,
    0x46,
    0x00,
    0x01,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x01,
    0x00,
    0x00,
    if (withEoi) ...[0xFF, 0xD9],
  ]);
}

void main() {
  group('stripPngPrefix', () {
    test('passes through non-PNG data', () {
      final data = Uint8List.fromList([0x47, 0x40, 0x00, 0x10]);
      expect(stripPngPrefix(data), same(data));
    });

    test('strips PNG signature and finds TS sync every 188 bytes', () {
      final ts = _tsPair();
      final data = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        ...ts,
      ]);
      final stripped = stripPngPrefix(data);
      expect(stripped.first, 0x47);
      expect(stripped.length, 376);
    });

    test('falls back to dropping 8-byte signature', () {
      final data = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x01,
        0x02,
        0x03,
      ]);
      expect(stripPngPrefix(data), Uint8List.fromList([0x01, 0x02, 0x03]));
    });
  });

  group('stripImagePrefix jpeg', () {
    test('detects jpeg disguise', () {
      expect(hlsImageDisguiseKind(_jpegPrefix()), 'jpeg');
      expect(hlsImageDisguiseKind(_tsPair()), isNull);
    });

    test('strips jpeg prefix and finds TS sync', () {
      final data = Uint8List.fromList([
        ..._jpegPrefix(),
        ..._tsPair(),
      ]);
      final stripped = stripImagePrefix(data);
      expect(stripped.first, 0x47);
      expect(stripped.length, 376);
    });

    test('falls back to bytes after jpeg EOI when no TS sync', () {
      final data = Uint8List.fromList([
        ..._jpegPrefix(),
        0x00,
        0x01,
        0x02,
        0x03,
      ]);
      expect(
        stripImagePrefix(data),
        Uint8List.fromList([0x00, 0x01, 0x02, 0x03]),
      );
    });

    test('passes through jpeg without EOI or TS', () {
      final data = _jpegPrefix(withEoi: false);
      expect(stripImagePrefix(data), same(data));
    });

    test('does not treat raw mpeg-ts as an image', () {
      final ts = _tsPair();
      expect(stripImagePrefix(ts), same(ts));
    });
  });

  group('stripImagePrefix gif and webp', () {
    test('strips gif prefix before TS', () {
      final data = Uint8List.fromList([
        0x47,
        0x49,
        0x46,
        0x38,
        0x39,
        0x61,
        0x00,
        0x00,
        ..._tsPair(),
      ]);
      expect(hlsImageDisguiseKind(data), 'gif');
      final stripped = stripImagePrefix(data);
      expect(stripped.first, 0x47);
      expect(stripped.length, 376);
    });

    test('strips webp prefix before TS', () {
      final data = Uint8List.fromList([
        0x52,
        0x49,
        0x46,
        0x46,
        0x00,
        0x00,
        0x00,
        0x00,
        0x57,
        0x45,
        0x42,
        0x50,
        0x00,
        ..._tsPair(),
      ]);
      expect(hlsImageDisguiseKind(data), 'webp');
      final stripped = stripImagePrefix(data);
      expect(stripped.first, 0x47);
      expect(stripped.length, 376);
    });
  });

  group('isHlsPlaylist', () {
    test('detects EXTM3U', () {
      expect(
        isHlsPlaylist(Uint8List.fromList(utf8.encode('#EXTM3U\n#EXTINF:1,\n'))),
        isTrue,
      );
      expect(
        isHlsPlaylist(Uint8List.fromList(utf8.encode('not a playlist'))),
        isFalse,
      );
    });
  });

  group('rewritePlaylist', () {
    test('rewrites segment lines and URI attributes', () {
      const body = '''
#EXTM3U
#EXT-X-KEY:METHOD=AES-128,URI="key.key"
#EXTINF:4.0,
seg1.ts
https://cdn.example/seg2.ts
''';
      final out = rewritePlaylist(
        body,
        'https://cdn.example/path/index.m3u8',
        'http://127.0.0.1:9/p',
      );
      expect(
        out,
        contains(
          'URI="http://127.0.0.1:9/p?u=${Uri.encodeQueryComponent('https://cdn.example/path/key.key')}"',
        ),
      );
      expect(
        out,
        contains(
          'http://127.0.0.1:9/p?u=${Uri.encodeQueryComponent('https://cdn.example/path/seg1.ts')}',
        ),
      );
      expect(
        out,
        contains(
          'http://127.0.0.1:9/p?u=${Uri.encodeQueryComponent('https://cdn.example/seg2.ts')}',
        ),
      );
      expect(out.contains('\nseg1.ts\n'), isFalse);
    });
  });
}
