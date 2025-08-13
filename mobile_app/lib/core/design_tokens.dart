import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

// Design tokens and ThemeExtensions for spacing, radius, and elevation.

@immutable
class SpacingTheme extends ThemeExtension<SpacingTheme> {
	const SpacingTheme({
		this.xs = 4,
		this.sm = 8,
		this.md = 12,
		this.lg = 16,
		this.xl = 24,
		this.xxl = 32,
	});

	final double xs;
	final double sm;
	final double md;
	final double lg;
	final double xl;
	final double xxl;

	@override
	SpacingTheme copyWith({double? xs, double? sm, double? md, double? lg, double? xl, double? xxl}) {
		return SpacingTheme(
			xs: xs ?? this.xs,
			sm: sm ?? this.sm,
			md: md ?? this.md,
			lg: lg ?? this.lg,
			xl: xl ?? this.xl,
			xxl: xxl ?? this.xxl,
		);
	}

	@override
	SpacingTheme lerp(ThemeExtension<SpacingTheme>? other, double t) {
		if (other is! SpacingTheme) return this;
		return SpacingTheme(
			xs: lerpDouble(xs, other.xs, t)!,
			sm: lerpDouble(sm, other.sm, t)!,
			md: lerpDouble(md, other.md, t)!,
			lg: lerpDouble(lg, other.lg, t)!,
			xl: lerpDouble(xl, other.xl, t)!,
			xxl: lerpDouble(xxl, other.xxl, t)!,
		);
	}
}

@immutable
class RadiusTheme extends ThemeExtension<RadiusTheme> {
	const RadiusTheme({
		this.sm = const Radius.circular(6),
		this.md = const Radius.circular(12),
		this.lg = const Radius.circular(16),
	});

	final Radius sm;
	final Radius md;
	final Radius lg;

	BorderRadius get brSm => BorderRadius.all(sm);
	BorderRadius get brMd => BorderRadius.all(md);
	BorderRadius get brLg => BorderRadius.all(lg);

	@override
	RadiusTheme copyWith({Radius? sm, Radius? md, Radius? lg}) {
		return RadiusTheme(
			sm: sm ?? this.sm,
			md: md ?? this.md,
			lg: lg ?? this.lg,
		);
	}

	@override
	RadiusTheme lerp(ThemeExtension<RadiusTheme>? other, double t) {
		if (other is! RadiusTheme) return this;
		return RadiusTheme(
			sm: Radius.lerp(sm, other.sm, t)!,
			md: Radius.lerp(md, other.md, t)!,
			lg: Radius.lerp(lg, other.lg, t)!,
		);
	}
}

@immutable
class ElevationTheme extends ThemeExtension<ElevationTheme> {
	const ElevationTheme({
		this.level0 = 0,
		this.level1 = 1,
		this.level2 = 2,
		this.level3 = 3,
		this.level4 = 4,
		this.level6 = 6,
	});

	final double level0;
	final double level1;
	final double level2;
	final double level3;
	final double level4;
	final double level6;

	@override
	ElevationTheme copyWith({double? level0, double? level1, double? level2, double? level3, double? level4, double? level6}) {
		return ElevationTheme(
			level0: level0 ?? this.level0,
			level1: level1 ?? this.level1,
			level2: level2 ?? this.level2,
			level3: level3 ?? this.level3,
			level4: level4 ?? this.level4,
			level6: level6 ?? this.level6,
		);
	}

	@override
	ElevationTheme lerp(ThemeExtension<ElevationTheme>? other, double t) {
		if (other is! ElevationTheme) return this;
		return ElevationTheme(
			level0: lerpDouble(level0, other.level0, t)!,
			level1: lerpDouble(level1, other.level1, t)!,
			level2: lerpDouble(level2, other.level2, t)!,
			level3: lerpDouble(level3, other.level3, t)!,
			level4: lerpDouble(level4, other.level4, t)!,
			level6: lerpDouble(level6, other.level6, t)!,
		);
	}
}

class AppColors {
	AppColors._();
	// Primary brand seed (from current theme)
	static const Color seed = Color(0xFF2F6FED);
	static const Color success = Color(0xFF1DB954);
	static const Color warning = Color(0xFFF5A524);
	static const Color error = Color(0xFFDC3545);
}

class AppTypography {
	AppTypography._();

	static TextTheme light(ColorScheme scheme) {
		return TextTheme(
			displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, color: scheme.onSurface),
			displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: scheme.onSurface),
			displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: scheme.onSurface),
			headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: scheme.onSurface),
			headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: scheme.onSurface),
			headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: scheme.onSurface),
			titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: scheme.onSurface),
			titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: scheme.onSurface),
			titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: scheme.onSurface),
			labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: scheme.onPrimary),
			labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: scheme.onSurfaceVariant),
			labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: scheme.onSurfaceVariant),
			bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, color: scheme.onSurface),
			bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: scheme.onSurface),
			bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: scheme.onSurfaceVariant),
		);
	}

	static TextTheme dark(ColorScheme scheme) {
		// Use same sizes/weights; colors adapt to scheme
		return light(scheme);
	}
}

extension AppThemeX on BuildContext {
	SpacingTheme get spacing => Theme.of(this).extension<SpacingTheme>()!;
	RadiusTheme get radii => Theme.of(this).extension<RadiusTheme>()!;
	ElevationTheme get elevations => Theme.of(this).extension<ElevationTheme>()!;
}


