import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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
      backgroundColor: Colors.white,
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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffeeeeee))),
      ),
      child: Row(
        children: [
          const Text('🌼', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          const Text(
            'daisyUI',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width >= 420)
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 3),
                ),
              ),
              child: const Center(
                widthFactor: 1,
                child: Text(
                  'Components',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Components', style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 40),
            Text('Actions', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xff171717),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Button',
                style: TextStyle(color: Colors.white),
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
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Button',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Pasa el ratón por encima y mantén pulsado el botón para probar su elevación.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 40),
              const Text(
                'Elevación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffe8e8e8)),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
                child: const Text('Preview'),
              ),
              Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffe8e8e8)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomPaint(
                  painter: _StripesPainter(),
                  child: Center(
                    child: DaisyButton(
                      onPressed: () {},
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f4f4),
                          border: Border.all(color: const Color(0xffe2e2e2)),
                          borderRadius: BorderRadius.circular(
                            context.daisyTheme.radius.fields.toDouble(),
                          ),
                        ),
                        child: const Text(
                          'Button',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xfff2f2f2)
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
  bool shouldRepaint(covariant _StripesPainter oldDelegate) => false;
}
