import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/youtube/json_node.dart';

void main() {
  group('JsonNode.integer', () {
    test('reads ints', () {
      expect(const JsonNode(18).integer, 18);
    });

    test('truncates doubles', () {
      expect(const JsonNode(29.97).integer, 29);
      expect(const JsonNode(double.nan).integer, isNull);
      expect(const JsonNode(double.infinity).integer, isNull);
    });

    test('parses numeric strings', () {
      expect(const JsonNode('1234567').integer, 1234567);
      expect(const JsonNode(' 42 ').integer, 42);
      expect(const JsonNode('12.9').integer, 12);
    });

    test('is null for anything else', () {
      expect(const JsonNode(null).integer, isNull);
      expect(const JsonNode('').integer, isNull);
      expect(const JsonNode('abc').integer, isNull);
      expect(const JsonNode('Infinity').integer, isNull);
      expect(const JsonNode(true).integer, isNull);
      expect(const JsonNode({'a': 1}).integer, isNull);
    });

    test('works through missing keys', () {
      const node = JsonNode({
        'format': {'itag': '22'},
      });
      expect(node['format']['itag'].integer, 22);
      expect(node['format']['height'].integer, isNull);
    });
  });
}
