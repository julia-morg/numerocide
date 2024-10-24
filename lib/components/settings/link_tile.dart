import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTile extends StatelessWidget {
  final String title;
  final String webPagePath;

  const LinkTile({
    super.key,
    required this.title,
    required this.webPagePath,
  });

  void _launchWebPage(BuildContext context) async {
    Uri url = Uri(scheme: 'https', host: 'julia_morg.tilda.ws', path: webPagePath);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = Theme.of(context).textTheme.displaySmall!.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.primary,
    );
    return TextButton(
      onPressed: () => _launchWebPage(context),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: linkStyle,
            ),
          ],
        ),
      ),
    );
  }
}