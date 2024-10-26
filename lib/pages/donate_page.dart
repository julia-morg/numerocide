import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:numerocide/components/dialog_action.dart';
import 'package:numerocide/components/popup_dialog.dart';
import '../components/default_scaffold.dart';
import '../game/save.dart';
import '../game/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DonatePage extends StatefulWidget {
  final Settings settings;
  final Save save;

  const DonatePage({super.key, required this.settings, required this.save});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {

  final List<double> donations = [1, 5, 10, 25, 50, 100];
  final String donationProductPrefix = 'donation_';

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    return DefaultScaffold(
      title: AppLocalizations.of(context)!.donatePageHeader,
      settings: widget.settings,
      save: widget.save,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.donatePageText,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${AppLocalizations.of(context)!.donatePageOption}\$${donations[index]}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(Icons.payment, color: colorDark,),
                    onTap: () => _processDonation(context, donations[index]),
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
        return PopupDialog(
            title: AppLocalizations.of(context)!.donatePagePopupTitle,
            content: '${AppLocalizations.of(context)!.donatePagePopupText}\$$amount',
            note: AppLocalizations.of(context)!.donatePagePopupNote,
            actions:  <DialogAction>[
              DialogAction(
                text: AppLocalizations.of(context)!.donatePagePopupCancel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              DialogAction(
                text: AppLocalizations.of(context)!.donatePagePopupConfirm,
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool result = await _processPayment(amount);
                  _showSnackBar(result, amount);
                },
              ),
            ]);
      },
    );
  }

  void _showSnackBar(bool result, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: result ? Colors.green : Colors.red,
        content: Text(result
            ? AppLocalizations.of(context)!.donatePageThanks(amount)
            : AppLocalizations.of(context)!.donatePageFail),
      ),
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
