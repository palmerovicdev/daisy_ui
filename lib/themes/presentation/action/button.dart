import 'package:flutter/material.dart';

import '../../core/extension/build_context.dart';
import '../../domain/button/button_modifier.dart';
import '../../domain/button_theme.dart';

class DaisyButton extends StatefulWidget {
  const DaisyButton({
    super.key,
    required this.child,
    this.enabled = true,
    this.theme = const DaisyButtonTheme(),
    this.onPressed,
    this.onLongPress,
    this.onHover,
  });

  final bool enabled;
  final Widget? child;
  final DaisyButtonTheme? theme;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;

  @override
  State<DaisyButton> createState() => _DaisyButtonState();
}

class _DaisyButtonState extends State<DaisyButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  bool get _isEnabled =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPress != null);

  @override
  void didUpdateWidget(covariant DaisyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEnabled) {
      _isHovering = false;
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = context.daisyTheme;
    final shape = widget.theme?.modifier == DaisyButtonModifier.circle
        ? CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(th.radius.fields.toDouble()),
          );
    final elevation = _isPressed
        ? widget.theme?.pressedElevation ?? 0
        : _isHovering
        ? widget.theme?.hoverElevation ?? widget.theme?.elevation ?? 0
        : widget.theme?.elevation ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: elevation),
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      builder: (context, value, child) => Material(
        color: Colors.transparent,
        shape: shape,
        elevation: value,
        animationDuration: Duration.zero,
        child: child,
      ),
      child: InkWell(
        onTap: _isEnabled ? widget.onPressed : null,
        onLongPress: _isEnabled ? widget.onLongPress : null,
        onLongPressUp: _isEnabled && widget.onLongPress != null
            ? () => _setPressed(false)
            : null,
        onHighlightChanged: _isEnabled ? _setPressed : null,
        onHover: _isEnabled
            ? (value) {
                setState(() => _isHovering = value);
                widget.onHover?.call(value);
              }
            : null,
        customBorder: shape,
        mouseCursor: _isEnabled ? SystemMouseCursors.click : null,
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }
}
