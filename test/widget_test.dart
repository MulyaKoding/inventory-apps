import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_inventory/screens/login_screen.dart';

void main() {
  test('extractDisplayName uses API user name instead of email', () {
    final data = {
      'user': {
        'id': '69d334c36a7974ea9ecb5195',
        'name': 'Rudi ',
        'email': 'rahmatseru43@gmail.com',
        'role': 'user',
      },
    };

    expect(extractDisplayName(data), 'Rudi');
  });

  test('sanity check', () {
    expect(1 + 1, 2);
  });
}