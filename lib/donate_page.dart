import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:numerocide/settings_page.dart';
import 'game/settings.dart';


class DonatePage extends StatefulWidget {
  final Settings settings;

  const DonatePage({super.key, required this.settings});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {

  final List<double> donations = [1, 5, 10, 25, 50, 100];
  final String donationProductPrefix = 'donation_';

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    settings: widget.settings,
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
              'This game contains no advertisements and is available for free.\nIf you would like to support the developer, here are the available donation options:',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Donate \$${donations[index]}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    trailing: Icon(Icons.payment, color: colorDark,),
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
          title: const Text('Confirm Donation'),
          titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20,),
          content: Text(
            'You are about to donate \$$amount. This action cannot be undone. Do you want to proceed?',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: Theme.of(context).textTheme.titleLarge),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm', style: Theme.of(context).textTheme.titleLarge),
              onPressed: () async {
                bool result = await _processPayment(amount);
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ? 'Thank you for donating \$$amount!' : 'Failed to process donation'),
                  ),
                );
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
      debugPrint('In-app purchases not available');
      return false;
    }
    final ProductDetailsResponse response =
        await inAppPurchase.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found: $productId');
      return false;
    }
    final productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    return inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }
}
