import 'package:flutter_test/flutter_test.dart';
import 'package:mukke_app/services/auth_error_mapper.dart';

void main() {
  test('maps known firebase auth codes to german messages', () {
    expect(mapFirebaseAuthErrorCodeToMessage('wrong-password'), contains('Passwort'));
    expect(mapFirebaseAuthErrorCodeToMessage('invalid-email'), contains('E-Mail'));
    expect(mapFirebaseAuthErrorCodeToMessage('email-already-in-use'), contains('bereits'));
  });

  test('unknown codes contain the code in message', () {
    expect(mapFirebaseAuthErrorCodeToMessage('some-new-code'), contains('some-new-code'));
  });
}
