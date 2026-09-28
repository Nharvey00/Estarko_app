import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/main.dart';

void main() {
  test('EstarKoApp smoke test', () {
    const app = EstarKoApp();
    expect(app, isNotNull);
  });
}
