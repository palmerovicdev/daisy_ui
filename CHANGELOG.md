## 0.0.1

* Provide 35 built-in DaisyUI themes, immutable design tokens and reactive theme
  scopes as a Flutter package.
* Add the public `package:daisy_ui/daisy_ui.dart` entry point.
* Remove native plugin implementations and platform registration.
* Encapsulate theme signals behind read-only listenables and add independent
  controllers for nested scopes.
* Serialize nested theme tokens as JSON maps and cover direct map round trips.
* Initialize the global theme service explicitly and use `DaisyThemeScope`
  for global and independent themes; theme persistence is not implemented.
* Demonstrate the global theme scope in the example application.
