import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('requires a value', () {
      expect(Validators.email(''), 'Email wajib diisi');
    });

    test('rejects an invalid email address', () {
      expect(Validators.email('abc'), 'Format email tidak valid');
    });

    test('accepts a valid email address', () {
      expect(Validators.email('imam@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(''), 'Password wajib diisi');
    });

    test('requires at least eight characters', () {
      expect(Validators.password('123'), 'Password minimal 8 karakter');
    });

    test('accepts eight or more characters', () {
      expect(Validators.password('rahasia1'), isNull);
    });
  });

  test('minLength trims input before checking its length', () {
    expect(
      Validators.minLength('  abc  ', 5, fieldName: 'Catatan'),
      'Catatan minimal 5 karakter',
    );
  });

  group('Validators.rating', () {
    test('requires a numeric value from one to five', () {
      expect(Validators.rating('bagus'), 'Rating harus berupa angka');
      expect(Validators.rating('6'), 'Rating harus di antara 1 sampai 5');
      expect(Validators.rating('5'), isNull);
    });
  });
}
