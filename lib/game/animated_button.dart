import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String heroTag;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.heroTag,
  });

  @override
  State<AnimatedButton> createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 5, end: -5)
        .chain(CurveTween(curve: Curves.elasticInOut))
        .animate(_shakeController);
  }

  void startShakeAnimation() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse(from:-5);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _shakeAnimation.value),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            tooltip: 'Add',
            child: Icon(widget.icon, color: widget.color),
            heroTag: widget.heroTag,
          ),
        );
      },
    );
  }
}
