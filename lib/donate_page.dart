import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:numerocide/settings_page.dart';

import 'game/settings.dart';

class DonatePage extends StatelessWidget {
  final Settings settings;

  DonatePage({Key? key, required this.settings}) : super(key: key);

  final List<double> donations = [1, 5, 10, 25, 50, 100];
  final String donationProductPrefix = 'donation_';

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.surface;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate"),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: colorLight,
              fontSize: 22,
            ),
        backgroundColor: colorDark,
        iconTheme: IconThemeData(
          color: colorLight,
          size: 40.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    settings: settings,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Support Us by Donating",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: colorDark, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Donate \$${donations[index]}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: colorDark, fontSize: 18),
                    ),
                    trailing: const Icon(Icons.payment),
                    onTap: () {
                      _processDonation(context, donations[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processDonation(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Donation'),
          content: Text(
            'You are about to donate \$$amount. This action cannot be undone. Do you want to proceed?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                bool result = await _processPayment(amount);
                Navigator.of(context).pop(); // Закрываем диалог
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ? 'Thank you for donating \$$amount!' : 'Failed to process donation'),
                  ),
                );
                // Вызвать функцию для обработки платежа
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _processPayment(double amount) async {
    final InAppPurchase inAppPurchase = InAppPurchase.instance;
    final productId = '$donationProductPrefix$amount';
    bool available = await inAppPurchase.isAvailable();
    if (!available) {
      print("In-app purchases not available");
      return false;
    }
    final ProductDetailsResponse response =
        await inAppPurchase.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      print("Product not found: $productId");
      return false;
    }
    final productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    return inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }
}
