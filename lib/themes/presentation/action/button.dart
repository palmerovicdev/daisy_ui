import '../../application/daisy_theme_scope.dart';
import '../../core/extension/build_context.dart';
import '../../domain/theme.dart';

import 'package:flutter/material.dart';

import '../../domain/button/button_modifier.dart';
import '../../domain/button/button_size.dart';
import '../../domain/button/button_style.dart';
import '../../domain/button/button_type.dart';
import '../../domain/button_theme.dart';

/// A themed action whose [child] supplies its content, not its surface.
///
/// [theme] selects the color role, visual treatment, size, and shape. The
/// nearest [DaisyThemeScope] supplies the corresponding design tokens.
/// A button is disabled when [enabled] is false or both callbacks are null.
class DaisyButton extends StatefulWidget {
  const DaisyButton({
    super.key,
    required this.child,
    this.enabled = true,
    this.active = false,
    this.theme = const DaisyButtonTheme(),
    this.onPressed,
    this.onLongPress,
    this.onHover,
  });

  final bool enabled;

  /// Keeps the button visually active without simulating a press.
  final bool active;
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
    final theme = context.daisyTheme;
    final config = widget.theme;
    final size = _fieldSize(theme, config.size);
    final colors = _ButtonColors.resolve(theme, config, enabled: _isEnabled);
    final background = widget.active && _isEnabled
        ? Color.alphaBlend(
            colors.foreground.withValues(alpha: .16),
            colors.background,
          )
        : colors.background;
    final isCircle = config.modifier == DaisyButtonModifier.circle;
    final isOutlined = config.type == DaisyButtonType.outlined;
    final side = isOutlined
        ? BorderSide(color: colors.border, width: theme.border)
        : BorderSide.none;
    final shape = isCircle
        ? CircleBorder(side: side)
        : RoundedRectangleBorder(
            side: side,
            borderRadius: BorderRadius.circular(theme.radius.fields.toDouble()),
          );
    final elevation = !_isEnabled
        ? 0.0
        : _isPressed
        ? config.pressedElevation
        : _isHovering
        ? config.hoverElevation
        : config.elevation;

    final content = DefaultTextStyle.merge(
      style: TextStyle(
        color: colors.foreground,
        decoration: config.type == DaisyButtonType.link
            ? TextDecoration.underline
            : TextDecoration.none,
        decorationColor: colors.foreground,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.foreground),
        child: Center(widthFactor: 1, heightFactor: 1, child: widget.child),
      ),
    );
    final isCompact = isCircle || config.modifier == DaisyButtonModifier.square;
    final horizontalPadding = isCompact
        ? 0.0
        : size * (config.modifier == DaisyButtonModifier.wide ? .6 : .4);

    Widget button = TweenAnimationBuilder<double>(
      tween: Tween(end: elevation),
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      builder: (context, value, child) => Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        elevation: value,
        surfaceTintColor: Colors.transparent,
        animationDuration: Duration.zero,
        child: child,
      ),
      child: CustomPaint(
        foregroundPainter: config.type == DaisyButtonType.dashed
            ? _DashedBorderPainter(shape, colors.border, theme.border)
            : null,
        child: InkWell(
          onTap: _isEnabled ? widget.onPressed : null,
          onLongPress: _isEnabled ? widget.onLongPress : null,
          onLongPressUp: _isEnabled && widget.onLongPress != null
              ? () => _setPressed(false)
              : null,
          onHighlightChanged: _isEnabled ? _setPressed : null,
          onHover: _isEnabled
              ? (value) {
                  if (_isHovering != value) setState(() => _isHovering = value);
                  widget.onHover?.call(value);
                }
              : null,
          customBorder: shape,
          mouseCursor: _isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          hoverColor: colors.foreground.withValues(alpha: .08),
          focusColor: colors.foreground.withValues(alpha: .16),
          highlightColor: colors.foreground.withValues(alpha: .12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: content,
          ),
        ),
      ),
    );

    if (isCompact) {
      button = SizedBox.square(dimension: size, child: button);
    } else {
      button = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size,
          minWidth: config.modifier == DaisyButtonModifier.wide ? size * 3 : 0,
        ),
        child: button,
      );
      if (config.modifier == DaisyButtonModifier.block) {
        final content = button;
        button = LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: constraints.hasBoundedWidth ? double.infinity : null,
            child: content,
          ),
        );
      }
    }
    return Semantics(button: true, enabled: _isEnabled, child: button);
  }

  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }
}

double _fieldSize(DaisyThemeModel theme, DaisyButtonSize size) =>
    switch (size) {
      DaisyButtonSize.xs => theme.size.fields.xs.toDouble(),
      DaisyButtonSize.sm => theme.size.fields.sm.toDouble(),
      DaisyButtonSize.md => theme.size.fields.md.toDouble(),
      DaisyButtonSize.lg => theme.size.fields.lg.toDouble(),
      DaisyButtonSize.xl => theme.size.fields.xl.toDouble(),
    };

/// Resolves the visual recipe once, independently from widget layout.
class _ButtonColors {
  const _ButtonColors(this.background, this.foreground, this.border);

  final Color background;
  final Color foreground;
  final Color border;

  factory _ButtonColors.resolve(
    DaisyThemeModel theme,
    DaisyButtonTheme config, {
    required bool enabled,
  }) {
    final palette = theme.colors;
    final role = switch (config.style) {
      DaisyButtonStyle.neutral => palette.neutral,
      DaisyButtonStyle.primary => palette.primary,
      DaisyButtonStyle.secondary => palette.secondary,
      DaisyButtonStyle.accent => palette.accent,
      DaisyButtonStyle.info => palette.info,
      DaisyButtonStyle.success => palette.success,
      DaisyButtonStyle.warning => palette.warning,
      DaisyButtonStyle.error => palette.error,
    };
    if (!enabled) {
      final muted = palette.base.content.withValues(alpha: .38);
      return _ButtonColors(
        config.type == DaisyButtonType.filled ||
                config.type == DaisyButtonType.soft
            ? Color.alphaBlend(
                palette.base.content.withValues(alpha: .12),
                palette.base.base,
              )
            : Colors.transparent,
        muted,
        muted,
      );
    }
    return switch (config.type) {
      DaisyButtonType.filled => _ButtonColors(
        role.base,
        role.content,
        role.base,
      ),
      DaisyButtonType.soft => _softColors(role.base, palette.base.base),
      DaisyButtonType.outlined ||
      DaisyButtonType.dashed ||
      DaisyButtonType.ghost ||
      DaisyButtonType.link => _ButtonColors(
        Colors.transparent,
        _readableForeground(role.base, palette.base.base),
        role.base,
      ),
    };
  }
}

_ButtonColors _softColors(Color role, Color base) {
  final background = Color.alphaBlend(role.withValues(alpha: .15), base);
  final foreground = _readableForeground(role, background);
  return _ButtonColors(background, foreground, foreground);
}

// Keep the role hue where possible, adjusting toward the most legible endpoint
// only when its color would be difficult to read on the expected surface.
Color _readableForeground(Color color, Color background) {
  double contrast(Color foreground) {
    final first = foreground.computeLuminance();
    final second = background.computeLuminance();
    return (first > second ? first + .05 : second + .05) /
        (first < second ? first + .05 : second + .05);
  }

  if (contrast(color) >= 4.5) return color;
  final target = contrast(Colors.black) > contrast(Colors.white)
      ? Colors.black
      : Colors.white;
  var low = 0.0;
  var high = 1.0;
  for (var i = 0; i < 16; i++) {
    final middle = (low + high) / 2;
    if (contrast(Color.lerp(color, target, middle)!) >= 4.5) {
      high = middle;
    } else {
      low = middle;
    }
  }
  return Color.lerp(color, target, high)!;
}

/// Paints dashes along the same outline used for clipping and ink effects.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.shape, this.color, this.width);
  final ShapeBorder shape;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0) return;
    final rect = (Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final metric in shape.getOuterPath(rect).computeMetrics()) {
      for (double start = 0; start < metric.length; start += 8) {
        canvas.drawPath(
          metric.extractPath(start, (start + 4).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      width != oldDelegate.width;
}
