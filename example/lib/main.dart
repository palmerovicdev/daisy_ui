import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(child: const MaterialApp(home: _ThemeExample()));
  }
}

class _ThemeExample extends StatelessWidget {
  const _ThemeExample();

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;

    return Scaffold(
      backgroundColor: theme.colors.base.base,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 24,
                color: theme.colors.base.content,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DaisyThemeService.setTheme(
                theme.id == DaisyThemes.light.id
                    ? DaisyThemes.dark
                    : DaisyThemes.light,
              ),
              child: const Text('Switch theme'),
            ),
            const SizedBox(height: 32),
            const _ThemePreview(),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatefulWidget {
  const _ThemePreview();

  @override
  State<_ThemePreview> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<_ThemePreview> {
  late final DaisyThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: _controller,
      child: Builder(
        builder: (context) {
          final theme = context.daisyTheme;

          return Container(
            padding: const EdgeInsets.all(24),
            color: theme.colors.base.base,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preview: ${theme.name}',
                  style: TextStyle(color: theme.colors.base.content),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.setTheme(
                    theme.id == DaisyThemes.dark.id
                        ? DaisyThemes.cupcake
                        : DaisyThemes.dark,
                  ),
                  child: const Text('Switch preview theme'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
