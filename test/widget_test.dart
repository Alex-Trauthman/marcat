import 'package:flutter_test/flutter_test.dart';
import 'package:mar_cat/main.dart';

void main() {
  testWidgets('Smoke test inicial', (WidgetTester tester) async {
    // Constrói nosso app e aciona um frame inicial
    await tester.pumpWidget(const MarCatApp(isLoggedIn: false));

    // Como inicia deslogado, deve aparecer a tela de login
    expect(find.text('Entrar'), findsOneWidget);
  });
}
