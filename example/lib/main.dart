import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DaisyThemeService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _ButtonExample(),
      ),
    );
  }
}

class _ButtonExample extends StatelessWidget {
  const _ButtonExample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.daisyTheme.colors.base.base,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (constraints.maxWidth >= 700) const _Sidebar(),
                      const Expanded(child: _ButtonContent()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;
    final base = theme.colors.base;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: base.base300 ?? base.base,
            width: theme.border,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text('🌼', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Text(
            'daisyUI',
            style: TextStyle(
              color: base.content,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width >= 420)
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colors.primary.base,
                    width: 3,
                  ),
                ),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  'Components',
                  style: TextStyle(
                    color: base.content,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;
    final base = theme.colors.base;
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Components',
              style: TextStyle(color: base.content.withValues(alpha: 0.7)),
            ),
            Divider(
              height: 40,
              color: base.base300 ?? base.base,
              thickness: theme.border,
            ),
            Text(
              'Actions',
              style: TextStyle(color: base.content.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colors.neutral.base,
                borderRadius: BorderRadius.circular(
                  theme.radius.fields.toDouble(),
                ),
              ),
              child: Text(
                'Button',
                style: TextStyle(color: theme.colors.neutral.content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonContent extends StatefulWidget {
  const _ButtonContent();

  @override
  State<_ButtonContent> createState() => _ButtonContentState();
}

class _ButtonContentState extends State<_ButtonContent> {
  int _themeIndex = 0;

  void _cycleTheme() {
    final next = (_themeIndex + 1) % DaisyThemes.values.length;
    setState(() => _themeIndex = next);
    DaisyThemeService.setTheme(DaisyThemes.values[next]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;
    final base = theme.colors.base;

    Widget exampleButton(
      String label, {
      DaisyButtonType type = DaisyButtonType.filled,
      DaisyButtonStyle style = DaisyButtonStyle.neutral,
      DaisyButtonSize size = DaisyButtonSize.md,
      DaisyButtonModifier modifier = DaisyButtonModifier.none,
      bool enabled = true,
      bool active = false,
      Widget? child,
    }) => DaisyButton(
      theme: DaisyButtonTheme(
        type: type,
        style: style,
        size: size,
        modifier: modifier,
      ),
      enabled: enabled,
      active: active,
      onPressed: enabled ? _cycleTheme : null,
      child: child ?? Text(label),
    );

    List<Widget> colorButtons(DaisyButtonType type, {bool active = false}) => [
      for (final style in DaisyButtonStyle.values)
        exampleButton(
          style.name[0].toUpperCase() + style.name.substring(1),
          type: type,
          style: style,
          active: active,
        ),
    ];

    Widget section(String title, List<Widget> children) =>
        _ButtonPreviewSection(
          key: ValueKey('section-$title'),
          title: title,
          children: children,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Components / Actions',
                style: TextStyle(color: base.content.withValues(alpha: .7)),
              ),
              const SizedBox(height: 16),
              Text(
                'Button',
                style: TextStyle(
                  color: base.content,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore button variants. Tap a button to change the theme.',
                style: TextStyle(
                  color: base.content.withValues(alpha: .8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              section('Default button', [exampleButton('Default')]),
              section('Button sizes', [
                for (final size in DaisyButtonSize.values)
                  _SizedThemeButton(
                    key: ValueKey('sizes-wide-${size.name}'),
                    size: size,
                    onPressed: _cycleTheme,
                    modifier: DaisyButtonModifier.wide,
                  ),
              ]),
              section('Square button sizes', [
                for (final size in DaisyButtonSize.values)
                  _SizedThemeButton(
                    key: ValueKey('sizes-square-${size.name}'),
                    size: size,
                    onPressed: _cycleTheme,
                    modifier: DaisyButtonModifier.square,
                  ),
              ]),
              section('Responsive button', [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = MediaQuery.sizeOf(context).width;
                    final size = width < 640
                        ? DaisyButtonSize.xs
                        : width < 768
                        ? DaisyButtonSize.sm
                        : width < 1024
                        ? DaisyButtonSize.md
                        : width < 1280
                        ? DaisyButtonSize.lg
                        : DaisyButtonSize.xl;
                    return exampleButton('Responsive', size: size);
                  },
                ),
              ]),
              section('Button colors', colorButtons(DaisyButtonType.filled)),
              section('Soft buttons', colorButtons(DaisyButtonType.soft)),
              section(
                'Outline buttons',
                colorButtons(DaisyButtonType.outlined),
              ),
              section('Dash buttons', colorButtons(DaisyButtonType.dashed)),
              section('Neutral outline and dash', [
                exampleButton('Outline', type: DaisyButtonType.outlined),
                exampleButton('Dash', type: DaisyButtonType.dashed),
              ]),
              section(
                'Active buttons',
                colorButtons(DaisyButtonType.filled, active: true),
              ),
              section('Ghost and link buttons', [
                exampleButton('Ghost', type: DaisyButtonType.ghost),
                exampleButton('Link', type: DaisyButtonType.link),
              ]),
              section('Wide button', [
                exampleButton('Wide', modifier: DaisyButtonModifier.wide),
              ]),
              section('Disabled buttons', [
                exampleButton('Disabled', enabled: false),
              ]),
              section('Square and circle buttons', [
                exampleButton(
                  'Like',
                  modifier: DaisyButtonModifier.square,
                  child: const Icon(
                    Icons.favorite_border,
                    semanticLabel: 'Like',
                  ),
                ),
                exampleButton(
                  'Like',
                  modifier: DaisyButtonModifier.circle,
                  child: const Icon(
                    Icons.favorite_border,
                    semanticLabel: 'Like',
                  ),
                ),
              ]),
              section('Button with icon', [
                exampleButton(
                  'Like',
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 18),
                      SizedBox(width: 8),
                      Text('Like'),
                    ],
                  ),
                ),
                exampleButton(
                  'Like',
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Like'),
                      SizedBox(width: 8),
                      Icon(Icons.favorite_border, size: 18),
                    ],
                  ),
                ),
              ]),
              section('Block button', [
                SizedBox(
                  width: double.infinity,
                  child: exampleButton(
                    'Block',
                    modifier: DaisyButtonModifier.block,
                  ),
                ),
              ]),
              section('Button with loading spinner', [
                exampleButton(
                  'Loading',
                  modifier: DaisyButtonModifier.square,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                exampleButton(
                  'Loading',
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading'),
                    ],
                  ),
                ),
              ]),
              section('Login buttons (unbranded examples)', [
                for (final provider in [
                  'Email',
                  'GitHub',
                  'Google',
                  'Facebook',
                  'X',
                  'Kakao',
                  'Apple',
                  'Amazon',
                  'Microsoft',
                  'LINE',
                  'Slack',
                  'LinkedIn',
                  'VK',
                  'WeChat',
                  'MetaMask',
                ])
                  exampleButton(
                    'Login with $provider',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login, size: 18),
                        const SizedBox(width: 8),
                        Flexible(child: Text('Login with $provider')),
                      ],
                    ),
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonPreviewSection extends StatelessWidget {
  const _ButtonPreviewSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;
    final borderColor = theme.colors.base.base300 ?? theme.colors.base.base;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colors.base.content,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: theme.border),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(theme.radius.boxes.toDouble()),
              ),
            ),
            child: Text(
              'Preview',
              style: TextStyle(color: theme.colors.base.content),
            ),
          ),
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: theme.border),
              borderRadius: BorderRadius.circular(
                theme.radius.boxes.toDouble(),
              ),
            ),
            child: CustomPaint(
              painter: _StripesPainter(borderColor),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizedThemeButton extends StatelessWidget {
  const _SizedThemeButton({
    super.key,
    required this.size,
    required this.onPressed,
    required this.modifier,
  });

  final DaisyButtonSize size;
  final VoidCallback onPressed;
  final DaisyButtonModifier modifier;

  @override
  Widget build(BuildContext context) {
    return DaisyButton(
      theme: DaisyButtonTheme(size: size, modifier: modifier),
      onPressed: onPressed,
      child: Text(size.name),
    );
  }
}

class _StripesPainter extends CustomPainter {
  _StripesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 20) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripesPainter oldDelegate) =>
      color != oldDelegate.color;
}
