import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/services/hls/hls_png_strip_proxy.dart';

void main() {
  group('stripPngPrefix', () {
    test('passes through non-PNG data', () {
      final data = Uint8List.fromList([0x47, 0x40, 0x00, 0x10]);
      expect(stripPngPrefix(data), same(data));
    });

    test('strips PNG signature and finds TS sync every 188 bytes', () {
      final tsPacket = List<int>.filled(188, 0);
      tsPacket[0] = 0x47;
      final next = List<int>.filled(188, 0);
      next[0] = 0x47;
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
        ...tsPacket,
        ...next,
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
