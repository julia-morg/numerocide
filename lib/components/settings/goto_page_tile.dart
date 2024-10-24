import 'package:flutter/material.dart';

class GotoPageTile extends StatelessWidget {
  final String title;
  final IconData icon = Icons.arrow_forward;
  final Widget nextPage;

  const GotoPageTile({
    super.key,
    required this.title,
    required this.nextPage,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color splashColor = Theme.of(context).splashColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => nextPage,
          ),
        );
      },
      splashColor: splashColor,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: labelStyle,
            ),
            Icon(
              icon,
              color: colorDark,
            ),
          ],
        ),
      ),
    );
  }
}