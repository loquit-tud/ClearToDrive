import 'package:cleartodrive/domain/parsers/romanian_document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = RomanianDocumentParser(referenceNow: DateTime(2025, 6, 1));

  test('Valabilitate: 29.05.2025 - 28.05.2026 extracts 28.05.2026', () {
    const text = 'POLITA RCA Valabilitate: 29.05.2025 - 28.05.2026';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2026, 5, 28));
    expect(result.lowConfidence, isFalse);
  });

  test('de la 29/05/2025 pana la 28/05/2026 extracts 28/05/2026', () {
    const text =
        'Asigurare RCA Valabil de la 29/05/2025 pana la 28/05/2026';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2026, 5, 28));
  });

  test('multiple unrelated dates chooses validity end date', () {
    const text = '''
RCA ASIGURARE
Data emiterii: 01.01.2020
Data nasterii: 15.03.1980
Valabilitate: 29.05.2025 - 28.05.2026
''';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2026, 5, 28));
    expect(result.selectionReason, contains('end_of_range'));
  });

  test('single future expiry-like date near valabilitate', () {
    const text = 'RCA polita valabilitate pana la 30.12.2027';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2027, 12, 30));
  });

  test('Perioada de valabilitate de la ... până la', () {
    const text =
        'Perioada de valabilitate: de la 29.05.2025 până la 28.05.2026';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2026, 5, 28));
  });

  test('yyyy-MM-dd in range', () {
    const text = 'RCA valabilitate 2025-05-29 - 2026-05-28';
    final result = parser.parseRcaExpiry(text);
    expect(result.expiryDate, DateTime(2026, 5, 28));
  });
}
