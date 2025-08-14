import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockBirdList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Northern Cardinal')),
        ListTile(title: Text('Blue Jay')),
      ],
    );
  }
}

void main() {
  testWidgets('Bird list displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: MockBirdList())));

    expect(find.text('Northern Cardinal'), findsOneWidget);
    expect(find.text('Blue Jay'), findsOneWidget);
  });
}
