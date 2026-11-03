import 'dart:math';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
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

class _ButtonContent extends StatelessWidget {
  const _ButtonContent();

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;
    final base = theme.colors.base;
    final borderColor = base.base300 ?? base.base;
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
                style: TextStyle(color: base.content.withValues(alpha: 0.7)),
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
                'Pasa el ratón por encima y mantén pulsado el botón para probar su elevación.',
                style: TextStyle(
                  color: base.content.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Elevación',
                style: TextStyle(
                  color: base.content,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: theme.border),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(theme.radius.boxes.toDouble()),
                  ),
                ),
                child: Text('Preview', style: TextStyle(color: base.content)),
              ),
              Container(
                height: 200,
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
                  child: Center(
                    child: DaisyButton(
                      onPressed: () {
                        final randomIndex = Random().nextInt(
                          DaisyThemes.values.length,
                        );
                        DaisyThemeService.setTheme(
                          DaisyThemes.values[randomIndex],
                        );
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: base.base200 ?? base.base,
                          border: Border.all(
                            color: borderColor,
                            width: theme.border,
                          ),
                          borderRadius: BorderRadius.circular(
                            context.daisyTheme.radius.fields.toDouble(),
                          ),
                        ),
                        child: Text(
                          'Button',
                          style: TextStyle(
                            color: base.content,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
