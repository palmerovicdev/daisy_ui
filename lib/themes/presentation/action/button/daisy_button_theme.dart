import 'button_modifier.dart';
import 'button_size.dart';
import 'button_style.dart';
import 'button_type.dart';



class DaisyButtonTheme {
  const DaisyButtonTheme({
    required this.type,
    required this.style,
    required this.size,
    required this.modifier,
  });

  final DaisyButtonType type;
  final DaisyButtonStyle style;
  final DaisyButtonSize size;
  final DaisyButtonModifier modifier;
}