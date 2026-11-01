import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'button/button_modifier.dart';
import 'button/button_size.dart';
import 'button/button_style.dart';
import 'button/button_type.dart';
import 'button/daisy_button_theme.dart';

class DaisyButton extends StatefulWidget {
  const DaisyButton({
    super.key,
    this.theme = const DaisyButtonTheme(),
    this.enabled = true,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.onHover,
  });

  final DaisyButtonTheme theme;
  final bool enabled;
  final Widget? child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final Function()? onHover;

  @override
  State<DaisyButton> createState() => _DaisyButtonState();
}

class _DaisyButtonState extends State<DaisyButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
