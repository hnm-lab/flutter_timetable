import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

/// A non-DateTime header value, representing e.g. a festival stage.
class _Stage {
  final String name;
  const _Stage(this.name);

  @override
  bool operator ==(Object other) => other is _Stage && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

void main() {
  group('TimetableHeader', () {
    test('equality and hashCode are based on the wrapped value', () {
      final a = TimetableHeader(const _Stage('Main'));
      final b = TimetableHeader(const _Stage('Main'));
      final c = TimetableHeader(const _Stage('Second'));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('supports non-DateTime generic values', () {
      final header = TimetableHeader(const _Stage('Main'));
      expect(header.value, isA<_Stage>());
      expect(header.value.name, 'Main');
    });
  });

  group('TimetableCell', () {
    test('equality is based on hour and header', () {
      final header = TimetableHeader(const _Stage('Main'));
      final a = TimetableCell(10, header);
      final b = TimetableCell(10, TimetableHeader(const _Stage('Main')));
      final c = TimetableCell(11, header);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('fromDateTime derives hour and a date-only header', () {
      final cell = TimetableCell.fromDateTime(DateTime(2024, 1, 1, 13, 45));
      expect(cell.hour, 13);
      expect(cell.header.value, DateTime(2024, 1, 1));
    });
  });

  group('TimetableHeaderConfig', () {
    test('direct constructor supports custom header types', () {
      final headers = [
        TimetableHeader(const _Stage('A')),
        TimetableHeader(const _Stage('B')),
      ];
      final config =
          TimetableHeaderConfig<_Stage>(headers, (h) => h.value.name);
      expect(config.headers, headers);
      expect(config.nameFormatter(headers[1]), 'B');
    });

    test('dateTimeHeader generates sequential daily headers', () {
      final start = DateTime(2024, 3, 1);
      final config = TimetableHeaderConfig.dateTimeHeader(
        start: start,
        format: DateFormat('d'),
        duration: 3,
      );
      expect(config.headers.length, 3);
      expect(config.headers.map((h) => h.value),
          [DateTime(2024, 3, 1), DateTime(2024, 3, 2), DateTime(2024, 3, 3)]);
      expect(config.nameFormatter(config.headers[1]), '2');
    });
  });
}
