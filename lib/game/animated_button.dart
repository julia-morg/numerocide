import 'package:flutter/material.dart';

class AnimatedAddButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  const AnimatedAddButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  _AnimatedAddButtonState createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  void startShakeAnimation() {
    _shakeController.forward(from: 0);
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
          offset: Offset(_shakeAnimation.value, 0),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            tooltip: 'Add',
            child: Icon(widget.icon, color: widget.color),
          ),
        );
      },
    );
  }
}