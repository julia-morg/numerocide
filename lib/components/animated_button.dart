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
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -3.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(_shakeController);
  }

  void startShakeAnimation([int maxShakes = 1]) {
    int shakeCount = 0;

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        shakeCount++;
        if (shakeCount < maxShakes) {
          _shakeController.forward();
        } else {
          _shakeController.stop();
        }
      }
    });

    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color inactiveColor = Theme.of(context).colorScheme.onSecondary;
    Color activeColor = widget.color;
    Color lightColor = Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  onPressed: widget.active ? widget.onPressed : null,
                  heroTag: widget.heroTag,
                  mini: false,
                  backgroundColor: lightColor,
                  child: Icon(widget.icon,
                      color: widget.active ? activeColor : inactiveColor,
                      size: 32),
                ),
              ),
              if (widget.labelCount != null)
                Positioned(
                  key: Key('label-container-${widget.heroTag}'),
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
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: lightColor,
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