import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/services/hls/hls_aes.dart';
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

    test('finds EXTM3U after a jpeg prefix', () {
      final wrapped = Uint8List.fromList([
        ..._jpegPrefix(),
        ...utf8.encode('#EXTM3U\n#EXTINF:1,\nseg.jpg\n'),
      ]);
      expect(hlsPlaylistOffset(wrapped), _jpegPrefix().length);
      expect(isHlsPlaylist(wrapped), isTrue);
    });
  });

  group('rewritePlaylist', () {
    test('rewrites segment lines and URI attributes', () {
      const body = '''
#EXTM3U
#EXT-X-KEY:METHOD=AES-128,URI="key.key"
#EXTINF:4.0,
seg1.ts
https://cdn.example/seg2.jpg
''';
      final out = rewritePlaylist(
        body,
        'https://cdn.example/path/index.m3u8',
        'http://127.0.0.1:9',
      );
      expect(
        out,
        contains(
          'URI="${proxiedUrl(
            'https://cdn.example/path/key.key',
            'http://127.0.0.1:9',
            name: 'key.bin',
          )}"',
        ),
      );
      expect(
        out,
        contains(
          proxiedUrl(
            'https://cdn.example/path/seg1.ts',
            'http://127.0.0.1:9',
            name: 'seg.ts',
            sequence: 0,
          ),
        ),
      );
      expect(
        out,
        contains(
          proxiedUrl(
            'https://cdn.example/seg2.jpg',
            'http://127.0.0.1:9',
            name: 'seg.ts',
            sequence: 1,
          ),
        ),
      );
      expect(out.contains('\nseg1.ts\n'), isFalse);
      expect(out.trim().split('\n').last.endsWith('n=seg.ts'), isTrue);
      expect(out.contains('#EXT-X-KEY'), isTrue);
    });

    test('drops AES key tags when decrypting in the proxy', () {
      const body = '''
#EXTM3U
#EXT-X-KEY:METHOD=AES-128,URI="key.key"
#EXTINF:4.0,
seg.jpg
''';
      final out = rewritePlaylist(
        body,
        'https://cdn.example/index.m3u8',
        'http://127.0.0.1:9',
        stripAesKey: true,
      );
      expect(out.contains('#EXT-X-KEY'), isFalse);
      expect(out, contains('n=seg.ts'));
    });
  });

  group('parseHlsAes128', () {
    test('reads key URI, IV, and media sequence', () {
      const body = '''
#EXTM3U
#EXT-X-MEDIA-SEQUENCE:7
#EXT-X-KEY:METHOD=AES-128,URI="key.key",IV=0x00000000000000000000000000000007
#EXTINF:4.0,
seg.jpg
''';
      final parsed = parseHlsAes128(body, 'https://cdn.example/path/index.m3u8');
      expect(parsed, isNotNull);
      expect(parsed!.keyUrl, 'https://cdn.example/path/key.key');
      expect(parsed.mediaSequence, 7);
      expect(parsed.iv, isNotNull);
      expect(parsed.iv!.length, 16);
      expect(parsed.iv![15], 7);
    });
  });

  group('decryptHlsAes128', () {
    test('round-trips AES-128-CBC', () {
      final key = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final iv = Uint8List(16);
      final plain = Uint8List.fromList([..._jpegPrefix(), ..._tsPair()]);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
      );
      final encrypted = Uint8List.fromList(
        encrypter.encryptBytes(plain, iv: encrypt.IV(iv)).bytes,
      );
      expect(hlsImageDisguiseKind(encrypted), isNull);
      final decrypted = decryptHlsAes128(encrypted, key, iv: iv);
      expect(decrypted, plain);
      expect(stripImagePrefix(decrypted).first, 0x47);
    });
  });
}
