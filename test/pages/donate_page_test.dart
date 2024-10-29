import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/popup_dialog.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/pages/donate_page.dart';
import 'package:numerocide/game/settings.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class FakePurchaseParam extends Fake implements PurchaseParam {}

class MockSave extends Mock implements Save {}

void main() {
  late MockInAppPurchase mockInAppPurchase;

  setUpAll(() {
    registerFallbackValue(FakePurchaseParam());
  });

  setUp(() {
    mockInAppPurchase = MockInAppPurchase();
    when(() => mockInAppPurchase.isAvailable()).thenAnswer((_) async => true);
    when(() => mockInAppPurchase.queryProductDetails(any()))
        .thenAnswer((_) async => ProductDetailsResponse(
              productDetails: [
                ProductDetails(
                  id: 'donation_1',
                  title: 'Donate \$1.0',
                  description: 'Donate \$1.0',
                  price: '1.0',
                  currencyCode: 'USD',
                  rawPrice: 1.0,
                )
              ],
              notFoundIDs: [],
            ));
    when(() => mockInAppPurchase.buyConsumable(
            purchaseParam: any(named: 'purchaseParam')))
        .thenAnswer((_) async => true);
    when(() => mockInAppPurchase.buyConsumable(
            purchaseParam: any(named: 'purchaseParam')))
        .thenAnswer((_) async => true);
  });

  Future<void> pumpDonatePage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: DonatePage(
          settings:
              Settings(sound: true, vibro: true, theme: 'blue', language: 'en'),
          save: MockSave(),
          inAppPurchase: mockInAppPurchase,
        ),
      ),
    );
  }

  testWidgets('PopupDialog closes and shows SnackBar on Confirm tap', (WidgetTester tester) async {
    await pumpDonatePage(tester);

    await tester.tap(find.text('Donate \$1.0').first);
    await tester.pumpAndSettle();

    if (find.byType(PopupDialog).evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('CONFIRM'));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Thank you for donating \$1.0'), findsOneWidget);
  });

  testWidgets('PopupDialog closes and shows SnackBar on error', (WidgetTester tester) async {
    when(() => mockInAppPurchase.queryProductDetails(any()))
        .thenAnswer((_) async => ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: ['test_1'],
    ));
    await pumpDonatePage(tester);

    await tester.tap(find.text('Donate \$1.0').first);
    await tester.pumpAndSettle();

    if (find.byType(PopupDialog).evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('CONFIRM'));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to process donation'), findsOneWidget);
  });

  testWidgets('PopupDialog closes and shows SnackBar on not active', (WidgetTester tester) async {
    when(() => mockInAppPurchase.isAvailable()).thenAnswer((_) async => false);
    await pumpDonatePage(tester);

    await tester.tap(find.text('Donate \$1.0').first);
    await tester.pumpAndSettle();

    if (find.byType(PopupDialog).evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('CONFIRM'));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to process donation'), findsOneWidget);
  });


  testWidgets('PopupDialog closes when Cancel button is tapped',
      (WidgetTester tester) async {
    final settings = Settings(
      sound: true,
      vibro: true,
      theme: 'navy',
      language: 'en',
    );

    await tester.pumpWidget(
      MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          home: DonatePage(
            settings: settings,
            save: MockSave(),
          )),
    );

    await tester.tap(find.textContaining('\$1.0'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining(
            'This action cannot be undone. Do you want to proceed?'),
        findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining(
            'This action cannot be undone. Do you want to proceed?'),
        findsNothing);
  });
}
