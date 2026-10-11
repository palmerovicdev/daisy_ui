import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prism_flutter/prism_flutter.dart';

part 'generated/theme_color.freezed.dart';

part 'generated/theme_color.g.dart';

@freezed
abstract class DaisyThemeColor with _$DaisyThemeColor {
  const factory DaisyThemeColor({
    required DaisyThemeColorPair base,
    required DaisyThemeColorPair primary,
    required DaisyThemeColorPair secondary,
    required DaisyThemeColorPair accent,
    required DaisyThemeColorPair neutral,
    required DaisyThemeColorPair info,
    required DaisyThemeColorPair success,
    required DaisyThemeColorPair error,
    required DaisyThemeColorPair warning,
    required DaisyThemeColorPair danger,
  }) = _DaisyThemeColor;

  factory DaisyThemeColor.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeColorFromJson(json);
}

@freezed
abstract class DaisyThemeColorPair with _$DaisyThemeColorPair {
  const factory DaisyThemeColorPair({
    required RayOklch base,
    required RayOklch content,
    RayOklch? base200,
    RayOklch? base300,
  }) = _DaisyThemeColorPair;

  factory DaisyThemeColorPair.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeColorPairFromJson(json);
}

/// Tailwind CSS palette in OKLCH (source: pasted picker HTML).
///
/// Naming: `<family><shade>`, e.g. [slate50] is `slate-50`.
abstract final class DaisyThemeColorPalette {
  // Slate
  static const slate50 = RayOklch.fromComponents(0.98, 0.003, 247.858);
  static const slate100 = RayOklch.fromComponents(0.96, 0.007, 247.896);
  static const slate200 = RayOklch.fromComponents(0.92, 0.013, 255.508);
  static const slate300 = RayOklch.fromComponents(0.86, 0.022, 252.894);
  static const slate400 = RayOklch.fromComponents(0.7, 0.04, 256.788);
  static const slate500 = RayOklch.fromComponents(0.55, 0.046, 257.417);
  static const slate600 = RayOklch.fromComponents(0.44, 0.043, 257.281);
  static const slate700 = RayOklch.fromComponents(0.37, 0.044, 257.287);
  static const slate800 = RayOklch.fromComponents(0.27, 0.041, 260.031);
  static const slate900 = RayOklch.fromComponents(0.2, 0.042, 265.755);
  static const slate950 = RayOklch.fromComponents(0.12, 0.042, 264.695);

  // Gray
  static const gray50 = RayOklch.fromComponents(0.98, 0.002, 247.839);
  static const gray100 = RayOklch.fromComponents(0.96, 0.003, 264.542);
  static const gray200 = RayOklch.fromComponents(0.92, 0.006, 264.531);
  static const gray300 = RayOklch.fromComponents(0.87, 0.01, 258.338);
  static const gray400 = RayOklch.fromComponents(0.7, 0.022, 261.325);
  static const gray500 = RayOklch.fromComponents(0.55, 0.027, 264.364);
  static const gray600 = RayOklch.fromComponents(0.44, 0.03, 256.802);
  static const gray700 = RayOklch.fromComponents(0.37, 0.034, 259.733);
  static const gray800 = RayOklch.fromComponents(0.27, 0.033, 256.848);
  static const gray900 = RayOklch.fromComponents(0.21, 0.034, 264.665);
  static const gray950 = RayOklch.fromComponents(0.13, 0.028, 261.692);

  // Zinc
  static const zinc50 = RayOklch.fromComponents(0.98, 0, 0);
  static const zinc100 = RayOklch.fromComponents(0.96, 0.001, 286.375);
  static const zinc200 = RayOklch.fromComponents(0.92, 0.004, 286.32);
  static const zinc300 = RayOklch.fromComponents(0.87, 0.006, 286.286);
  static const zinc400 = RayOklch.fromComponents(0.7, 0.015, 286.067);
  static const zinc500 = RayOklch.fromComponents(0.55, 0.016, 285.938);
  static const zinc600 = RayOklch.fromComponents(0.44, 0.017, 285.786);
  static const zinc700 = RayOklch.fromComponents(0.37, 0.013, 285.805);
  static const zinc800 = RayOklch.fromComponents(0.27, 0.006, 286.033);
  static const zinc900 = RayOklch.fromComponents(0.21, 0.006, 285.885);
  static const zinc950 = RayOklch.fromComponents(0.14, 0.005, 285.823);

  // Neutral
  static const neutral50 = RayOklch.fromComponents(0.98, 0, 0);
  static const neutral100 = RayOklch.fromComponents(0.97, 0, 0);
  static const neutral200 = RayOklch.fromComponents(0.92, 0, 0);
  static const neutral300 = RayOklch.fromComponents(0.87, 0, 0);
  static const neutral400 = RayOklch.fromComponents(0.7, 0, 0);
  static const neutral500 = RayOklch.fromComponents(0.55, 0, 0);
  static const neutral600 = RayOklch.fromComponents(0.43, 0, 0);
  static const neutral700 = RayOklch.fromComponents(0.37, 0, 0);
  static const neutral800 = RayOklch.fromComponents(0.26, 0, 0);
  static const neutral900 = RayOklch.fromComponents(0.2, 0, 0);
  static const neutral950 = RayOklch.fromComponents(0.14, 0, 0);

  // Stone
  static const stone50 = RayOklch.fromComponents(0.98, 0.001, 106.423);
  static const stone100 = RayOklch.fromComponents(0.97, 0.001, 106.424);
  static const stone200 = RayOklch.fromComponents(0.92, 0.003, 48.717);
  static const stone300 = RayOklch.fromComponents(0.86, 0.005, 56.366);
  static const stone400 = RayOklch.fromComponents(0.7, 0.01, 56.259);
  static const stone500 = RayOklch.fromComponents(0.55, 0.013, 58.071);
  static const stone600 = RayOklch.fromComponents(0.44, 0.011, 73.639);
  static const stone700 = RayOklch.fromComponents(0.37, 0.01, 67.558);
  static const stone800 = RayOklch.fromComponents(0.26, 0.007, 34.298);
  static const stone900 = RayOklch.fromComponents(0.21, 0.006, 56.043);
  static const stone950 = RayOklch.fromComponents(0.14, 0.004, 49.25);

  // Red
  static const red50 = RayOklch.fromComponents(0.97, 0.013, 17.38);
  static const red100 = RayOklch.fromComponents(0.93, 0.032, 17.717);
  static const red200 = RayOklch.fromComponents(0.88, 0.062, 18.334);
  static const red300 = RayOklch.fromComponents(0.8, 0.114, 19.571);
  static const red400 = RayOklch.fromComponents(0.7, 0.191, 22.216);
  static const red500 = RayOklch.fromComponents(0.63, 0.237, 25.331);
  static const red600 = RayOklch.fromComponents(0.57, 0.245, 27.325);
  static const red700 = RayOklch.fromComponents(0.5, 0.213, 27.518);
  static const red800 = RayOklch.fromComponents(0.44, 0.177, 26.899);
  static const red900 = RayOklch.fromComponents(0.39, 0.141, 25.723);
  static const red950 = RayOklch.fromComponents(0.25, 0.092, 26.042);

  // Orange
  static const orange50 = RayOklch.fromComponents(0.98, 0.016, 73.684);
  static const orange100 = RayOklch.fromComponents(0.95, 0.038, 75.164);
  static const orange200 = RayOklch.fromComponents(0.9, 0.076, 70.697);
  static const orange300 = RayOklch.fromComponents(0.83, 0.128, 66.29);
  static const orange400 = RayOklch.fromComponents(0.75, 0.183, 55.934);
  static const orange500 = RayOklch.fromComponents(0.7, 0.213, 47.604);
  static const orange600 = RayOklch.fromComponents(0.64, 0.222, 41.116);
  static const orange700 = RayOklch.fromComponents(0.55, 0.195, 38.402);
  static const orange800 = RayOklch.fromComponents(0.47, 0.157, 37.304);
  static const orange900 = RayOklch.fromComponents(0.4, 0.123, 38.172);
  static const orange950 = RayOklch.fromComponents(0.26, 0.079, 36.259);

  // Amber
  static const amber50 = RayOklch.fromComponents(0.98, 0.022, 95.277);
  static const amber100 = RayOklch.fromComponents(0.96, 0.059, 95.617);
  static const amber200 = RayOklch.fromComponents(0.92, 0.12, 95.746);
  static const amber300 = RayOklch.fromComponents(0.87, 0.169, 91.605);
  static const amber400 = RayOklch.fromComponents(0.82, 0.189, 84.429);
  static const amber500 = RayOklch.fromComponents(0.76, 0.188, 70.08);
  static const amber600 = RayOklch.fromComponents(0.66, 0.179, 58.318);
  static const amber700 = RayOklch.fromComponents(0.55, 0.163, 48.998);
  static const amber800 = RayOklch.fromComponents(0.47, 0.137, 46.201);
  static const amber900 = RayOklch.fromComponents(0.41, 0.112, 45.904);
  static const amber950 = RayOklch.fromComponents(0.27, 0.077, 45.635);

  // Yellow
  static const yellow50 = RayOklch.fromComponents(0.98, 0.026, 102.212);
  static const yellow100 = RayOklch.fromComponents(0.97, 0.071, 103.193);
  static const yellow200 = RayOklch.fromComponents(0.94, 0.129, 101.54);
  static const yellow300 = RayOklch.fromComponents(0.9, 0.182, 98.111);
  static const yellow400 = RayOklch.fromComponents(0.85, 0.199, 91.936);
  static const yellow500 = RayOklch.fromComponents(0.79, 0.184, 86.047);
  static const yellow600 = RayOklch.fromComponents(0.68, 0.162, 75.834);
  static const yellow700 = RayOklch.fromComponents(0.55, 0.135, 66.442);
  static const yellow800 = RayOklch.fromComponents(0.47, 0.114, 61.907);
  static const yellow900 = RayOklch.fromComponents(0.42, 0.095, 57.708);
  static const yellow950 = RayOklch.fromComponents(0.28, 0.066, 53.813);

  // Lime
  static const lime50 = RayOklch.fromComponents(0.98, 0.031, 120.757);
  static const lime100 = RayOklch.fromComponents(0.96, 0.067, 122.328);
  static const lime200 = RayOklch.fromComponents(0.93, 0.127, 124.321);
  static const lime300 = RayOklch.fromComponents(0.89, 0.196, 126.665);
  static const lime400 = RayOklch.fromComponents(0.84, 0.238, 128.85);
  static const lime500 = RayOklch.fromComponents(0.76, 0.233, 130.85);
  static const lime600 = RayOklch.fromComponents(0.64, 0.2, 131.684);
  static const lime700 = RayOklch.fromComponents(0.53, 0.157, 131.589);
  static const lime800 = RayOklch.fromComponents(0.45, 0.124, 130.933);
  static const lime900 = RayOklch.fromComponents(0.4, 0.101, 131.063);
  static const lime950 = RayOklch.fromComponents(0.27, 0.072, 132.109);

  // Green
  static const green50 = RayOklch.fromComponents(0.98, 0.018, 155.826);
  static const green100 = RayOklch.fromComponents(0.96, 0.044, 156.743);
  static const green200 = RayOklch.fromComponents(0.92, 0.084, 155.995);
  static const green300 = RayOklch.fromComponents(0.87, 0.15, 154.449);
  static const green400 = RayOklch.fromComponents(0.79, 0.209, 151.711);
  static const green500 = RayOklch.fromComponents(0.72, 0.219, 149.579);
  static const green600 = RayOklch.fromComponents(0.62, 0.194, 149.214);
  static const green700 = RayOklch.fromComponents(0.52, 0.154, 150.069);
  static const green800 = RayOklch.fromComponents(0.44, 0.119, 151.328);
  static const green900 = RayOklch.fromComponents(0.39, 0.095, 152.535);
  static const green950 = RayOklch.fromComponents(0.26, 0.065, 152.934);

  // Emerald
  static const emerald50 = RayOklch.fromComponents(0.97, 0.021, 166.113);
  static const emerald100 = RayOklch.fromComponents(0.95, 0.052, 163.051);
  static const emerald200 = RayOklch.fromComponents(0.9, 0.093, 164.15);
  static const emerald300 = RayOklch.fromComponents(0.84, 0.143, 164.978);
  static const emerald400 = RayOklch.fromComponents(0.76, 0.177, 163.223);
  static const emerald500 = RayOklch.fromComponents(0.69, 0.17, 162.48);
  static const emerald600 = RayOklch.fromComponents(0.59, 0.145, 163.225);
  static const emerald700 = RayOklch.fromComponents(0.5, 0.118, 165.612);
  static const emerald800 = RayOklch.fromComponents(0.43, 0.095, 166.913);
  static const emerald900 = RayOklch.fromComponents(0.37, 0.077, 168.94);
  static const emerald950 = RayOklch.fromComponents(0.26, 0.051, 172.552);

  // Teal
  static const teal50 = RayOklch.fromComponents(0.98, 0.014, 180.72);
  static const teal100 = RayOklch.fromComponents(0.95, 0.051, 180.801);
  static const teal200 = RayOklch.fromComponents(0.91, 0.096, 180.426);
  static const teal300 = RayOklch.fromComponents(0.85, 0.138, 181.071);
  static const teal400 = RayOklch.fromComponents(0.77, 0.152, 181.912);
  static const teal500 = RayOklch.fromComponents(0.7, 0.14, 182.503);
  static const teal600 = RayOklch.fromComponents(0.6, 0.118, 184.704);
  static const teal700 = RayOklch.fromComponents(0.51, 0.096, 186.391);
  static const teal800 = RayOklch.fromComponents(0.43, 0.078, 188.216);
  static const teal900 = RayOklch.fromComponents(0.38, 0.063, 188.416);
  static const teal950 = RayOklch.fromComponents(0.27, 0.046, 192.524);

  // Cyan
  static const cyan50 = RayOklch.fromComponents(0.98, 0.019, 200.873);
  static const cyan100 = RayOklch.fromComponents(0.95, 0.045, 203.388);
  static const cyan200 = RayOklch.fromComponents(0.91, 0.08, 205.041);
  static const cyan300 = RayOklch.fromComponents(0.86, 0.127, 207.078);
  static const cyan400 = RayOklch.fromComponents(0.78, 0.154, 211.53);
  static const cyan500 = RayOklch.fromComponents(0.71, 0.143, 215.221);
  static const cyan600 = RayOklch.fromComponents(0.6, 0.126, 221.723);
  static const cyan700 = RayOklch.fromComponents(0.52, 0.105, 223.128);
  static const cyan800 = RayOklch.fromComponents(0.45, 0.085, 224.283);
  static const cyan900 = RayOklch.fromComponents(0.39, 0.07, 227.392);
  static const cyan950 = RayOklch.fromComponents(0.3, 0.056, 229.695);

  // Sky
  static const sky50 = RayOklch.fromComponents(0.97, 0.013, 236.62);
  static const sky100 = RayOklch.fromComponents(0.95, 0.026, 236.824);
  static const sky200 = RayOklch.fromComponents(0.9, 0.058, 230.902);
  static const sky300 = RayOklch.fromComponents(0.82, 0.111, 230.318);
  static const sky400 = RayOklch.fromComponents(0.74, 0.16, 232.661);
  static const sky500 = RayOklch.fromComponents(0.68, 0.169, 237.323);
  static const sky600 = RayOklch.fromComponents(0.58, 0.158, 241.966);
  static const sky700 = RayOklch.fromComponents(0.5, 0.134, 242.749);
  static const sky800 = RayOklch.fromComponents(0.44, 0.11, 240.79);
  static const sky900 = RayOklch.fromComponents(0.39, 0.09, 240.876);
  static const sky950 = RayOklch.fromComponents(0.29, 0.066, 243.157);

  // Blue
  static const blue50 = RayOklch.fromComponents(0.97, 0.014, 254.604);
  static const blue100 = RayOklch.fromComponents(0.93, 0.032, 255.585);
  static const blue200 = RayOklch.fromComponents(0.88, 0.059, 254.128);
  static const blue300 = RayOklch.fromComponents(0.8, 0.105, 251.813);
  static const blue400 = RayOklch.fromComponents(0.7, 0.165, 254.624);
  static const blue500 = RayOklch.fromComponents(0.62, 0.214, 259.815);
  static const blue600 = RayOklch.fromComponents(0.54, 0.245, 262.881);
  static const blue700 = RayOklch.fromComponents(0.48, 0.243, 264.376);
  static const blue800 = RayOklch.fromComponents(0.42, 0.199, 265.638);
  static const blue900 = RayOklch.fromComponents(0.37, 0.146, 265.522);
  static const blue950 = RayOklch.fromComponents(0.28, 0.091, 267.935);

  // Indigo
  static const indigo50 = RayOklch.fromComponents(0.96, 0.018, 272.314);
  static const indigo100 = RayOklch.fromComponents(0.93, 0.034, 272.788);
  static const indigo200 = RayOklch.fromComponents(0.87, 0.065, 274.039);
  static const indigo300 = RayOklch.fromComponents(0.78, 0.115, 274.713);
  static const indigo400 = RayOklch.fromComponents(0.67, 0.182, 276.935);
  static const indigo500 = RayOklch.fromComponents(0.58, 0.233, 277.117);
  static const indigo600 = RayOklch.fromComponents(0.51, 0.262, 276.966);
  static const indigo700 = RayOklch.fromComponents(0.45, 0.24, 277.023);
  static const indigo800 = RayOklch.fromComponents(0.39, 0.195, 277.366);
  static const indigo900 = RayOklch.fromComponents(0.35, 0.144, 278.697);
  static const indigo950 = RayOklch.fromComponents(0.25, 0.09, 281.288);

  // Violet
  static const violet50 = RayOklch.fromComponents(0.96, 0.016, 293.756);
  static const violet100 = RayOklch.fromComponents(0.94, 0.029, 294.588);
  static const violet200 = RayOklch.fromComponents(0.89, 0.057, 293.283);
  static const violet300 = RayOklch.fromComponents(0.81, 0.111, 293.571);
  static const violet400 = RayOklch.fromComponents(0.7, 0.183, 293.541);
  static const violet500 = RayOklch.fromComponents(0.6, 0.25, 292.717);
  static const violet600 = RayOklch.fromComponents(0.54, 0.281, 293.009);
  static const violet700 = RayOklch.fromComponents(0.49, 0.27, 292.581);
  static const violet800 = RayOklch.fromComponents(0.43, 0.232, 292.759);
  static const violet900 = RayOklch.fromComponents(0.38, 0.189, 293.745);
  static const violet950 = RayOklch.fromComponents(0.28, 0.141, 291.089);

  // Purple
  static const purple50 = RayOklch.fromComponents(0.97, 0.014, 308.299);
  static const purple100 = RayOklch.fromComponents(0.94, 0.033, 307.174);
  static const purple200 = RayOklch.fromComponents(0.9, 0.063, 306.703);
  static const purple300 = RayOklch.fromComponents(0.82, 0.119, 306.383);
  static const purple400 = RayOklch.fromComponents(0.71, 0.203, 305.504);
  static const purple500 = RayOklch.fromComponents(0.62, 0.265, 303.9);
  static const purple600 = RayOklch.fromComponents(0.55, 0.288, 302.321);
  static const purple700 = RayOklch.fromComponents(0.49, 0.265, 301.924);
  static const purple800 = RayOklch.fromComponents(0.43, 0.218, 303.724);
  static const purple900 = RayOklch.fromComponents(0.38, 0.176, 304.987);
  static const purple950 = RayOklch.fromComponents(0.29, 0.149, 302.717);

  // Fuchsia
  static const fuchsia50 = RayOklch.fromComponents(0.97, 0.017, 320.058);
  static const fuchsia100 = RayOklch.fromComponents(0.95, 0.037, 318.852);
  static const fuchsia200 = RayOklch.fromComponents(0.9, 0.076, 319.62);
  static const fuchsia300 = RayOklch.fromComponents(0.83, 0.145, 321.434);
  static const fuchsia400 = RayOklch.fromComponents(0.74, 0.238, 322.16);
  static const fuchsia500 = RayOklch.fromComponents(0.66, 0.295, 322.15);
  static const fuchsia600 = RayOklch.fromComponents(0.59, 0.293, 322.896);
  static const fuchsia700 = RayOklch.fromComponents(0.51, 0.253, 323.949);
  static const fuchsia800 = RayOklch.fromComponents(0.45, 0.211, 324.591);
  static const fuchsia900 = RayOklch.fromComponents(0.4, 0.17, 325.612);
  static const fuchsia950 = RayOklch.fromComponents(0.29, 0.136, 325.661);

  // Pink
  static const pink50 = RayOklch.fromComponents(0.97, 0.014, 343.198);
  static const pink100 = RayOklch.fromComponents(0.94, 0.028, 342.258);
  static const pink200 = RayOklch.fromComponents(0.89, 0.061, 343.231);
  static const pink300 = RayOklch.fromComponents(0.82, 0.12, 346.018);
  static const pink400 = RayOklch.fromComponents(0.71, 0.202, 349.761);
  static const pink500 = RayOklch.fromComponents(0.65, 0.241, 354.308);
  static const pink600 = RayOklch.fromComponents(0.59, 0.249, 0.584);
  static const pink700 = RayOklch.fromComponents(0.52, 0.223, 3.958);
  static const pink800 = RayOklch.fromComponents(0.45, 0.187, 3.815);
  static const pink900 = RayOklch.fromComponents(0.4, 0.153, 2.432);
  static const pink950 = RayOklch.fromComponents(0.28, 0.109, 3.907);

  // Rose
  static const rose50 = RayOklch.fromComponents(0.96, 0.015, 12.422);
  static const rose100 = RayOklch.fromComponents(0.94, 0.03, 12.58);
  static const rose200 = RayOklch.fromComponents(0.89, 0.058, 10.001);
  static const rose300 = RayOklch.fromComponents(0.81, 0.117, 11.638);
  static const rose400 = RayOklch.fromComponents(0.71, 0.194, 13.428);
  static const rose500 = RayOklch.fromComponents(0.64, 0.246, 16.439);
  static const rose600 = RayOklch.fromComponents(0.58, 0.253, 17.585);
  static const rose700 = RayOklch.fromComponents(0.51, 0.222, 16.935);
  static const rose800 = RayOklch.fromComponents(0.45, 0.188, 13.697);
  static const rose900 = RayOklch.fromComponents(0.41, 0.159, 10.272);
  static const rose950 = RayOklch.fromComponents(0.27, 0.105, 12.094);

  // Base
  static const white = RayOklch.fromComponents(1, 0, 0);
  static const black = RayOklch.fromComponents(0, 0, 0);
}
