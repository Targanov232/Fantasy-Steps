// Basic Flutter widget test for Fantasy Step app.

import 'package:flutter_test/flutter_test.dart';

import 'package:fantasy_step/main.dart';
import 'package:fantasy_step/src/data/step_storage.dart';

void main() {
  testWidgets('Home screen shows title and refresh button', (WidgetTester tester) async {
    await StepStorage.init();
    await tester.pumpWidget(const FantasyStepApp());

    expect(find.text('Путь к Роковой Горе'), findsOneWidget);
    expect(find.text('Обновить шаги'), findsOneWidget);
  });
}
