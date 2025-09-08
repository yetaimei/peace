// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:peace/main.dart';

void main() {
  testWidgets('Book of Answers app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BookOfAnswersApp());

    // Verify that the main title is displayed.
    expect(find.text('答案之书'), findsOneWidget);
    expect(find.text('Peace and Love'), findsOneWidget);
    expect(find.text('THE BOOK OF ANSWERS'), findsOneWidget);

    // Verify that the input field and button are present.
    expect(find.text('输入你的问题...'), findsOneWidget);
    expect(find.text('获取答案'), findsOneWidget);
  });
}
