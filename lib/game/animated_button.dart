import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String heroTag;
  final bool active;
  final int? labelCount;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.heroTag,
    required this.active,
    this.labelCount,
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
      _shakeController.reverse(from: -5);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color inactiveColor = Colors.grey;
    Color activeColor = widget.color;
    Color lightColor = Colors.white;
    Color lightInactiveColor = Colors.grey[200]!;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _shakeAnimation.value), // Анимация сдвига кнопки
          child: Stack(
            alignment: Alignment.center,
            children: [
              FloatingActionButton(
                onPressed: widget.active ? widget.onPressed : null,
                tooltip: 'Add',
                child: Icon(widget.icon,
                    color: widget.active ? activeColor : inactiveColor),
                heroTag: widget.heroTag,
              ),
              if (widget.labelCount != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.active ? activeColor : inactiveColor,
                    ),
                    child: Text(
                      '${widget.labelCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.active ? lightColor : lightInactiveColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}