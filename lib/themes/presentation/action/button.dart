import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/button/button_modifier.dart';
import '../../domain/button/button_size.dart';
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
  final Widget child;
  final DaisyButtonTheme theme;
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
    final shape = widget.theme.modifier == DaisyButtonModifier.circle
        ? CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(th.radius.fields.toDouble()),
          );
    final elevation = _isPressed
        ? widget.theme.pressedElevation
        : _isHovering
        ? widget.theme.hoverElevation
        : widget.theme.elevation;

    Widget child = _setModifier(th, widget.theme, widget.child);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: elevation),
      duration: const Duration(milliseconds: 70),
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
        child: child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  Widget _setModifier(
    DaisyThemeModel theme,
    DaisyButtonTheme buttonTheme,
    Widget child,
  ) {
    final modifier = buttonTheme.modifier;

    final size = switch (buttonTheme.size) {
      DaisyButtonSize.xs => theme.size.fields.xs,
      DaisyButtonSize.sm => theme.size.fields.sm,
      DaisyButtonSize.md => theme.size.fields.md,
      DaisyButtonSize.lg => theme.size.fields.lg,
      DaisyButtonSize.xl => theme.size.fields.xl,
    };

    return switch (modifier) {
      DaisyButtonModifier.wide => Padding(
        padding: EdgeInsets.symmetric(
          vertical: buttonTheme.size.value,
          horizontal: buttonTheme.size.value * 2,
        ),
        child: child,
      ),
      DaisyButtonModifier.block => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: buttonTheme.size.value),
          child: child,
        ),
      ),
      DaisyButtonModifier.square => SizedBox(
        width: size.toDouble(),
        height: size.toDouble(),
        child: child,
      ),
      DaisyButtonModifier.circle => Container(
        width: size.toDouble(),
        height: size.toDouble(),
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
      DaisyButtonModifier.none => child,
    };
  }
}
