import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// The ALU split bar.
///
/// The ALU wordmark cuts every letter horizontally: red on top, white (or
/// grey) underneath. This bar repeats that cut as a small signature accent
/// under headings and across hero panels, so the app reads as ALU even
/// where the logo is not on screen.
class AluSplitBar extends StatelessWidget {
  final double width;
  final double height;
  final Color? bottomColor;

  const AluSplitBar({
    super.key,
    this.width = 36,
    this.height = 6,
    this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = bottomColor ?? (isDark ? AppColors.aluWhite : AppColors.aluNavy);

    return ClipRRect(
      borderRadius: BorderRadius.circular(1.5),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            Expanded(child: Container(color: AppColors.aluRed)),
            Expanded(child: Container(color: bottom)),
          ],
        ),
      ),
    );
  }
}

/// Official ALU horizontal logo. The file ships on its own ALU navy
/// background (#002E6D), so place it on a navy surface for a seamless edge.
class AluHorizontalLogo extends StatelessWidget {
  final double height;

  const AluHorizontalLogo({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/alu_logo_horizontal.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'African Leadership University',
    );
  }
}

/// Square ALU mark (navy tile with the split ALU letters).
class AluMark extends StatelessWidget {
  final double size;
  final double radius;

  const AluMark({super.key, this.size = 40, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/brand/alu_mark.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
        semanticLabel: 'ALU',
      ),
    );
  }
}
