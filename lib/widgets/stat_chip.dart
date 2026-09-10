import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single flat "stat chip" used for BOTH the stars and the day-streak
/// counters everywhere they appear — the dashboard header, the progress
/// panel, and the profile-switcher cards — so all three screens show one
/// identical card instead of three different treatments.
///
/// Build it with [StatChip.stars] / [StatChip.streak] so the icon and colour
/// for each stat can never drift apart across screens. Pass a [label] for the
/// fuller "icon + value + label" form (progress panel); omit it for the
/// compact "icon + value" pill (dashboard header, profile cards).
///
/// The chip carries its own opaque pale-tinted background, so it reads on a
/// coloured header image as well as on a plain white card — the old
/// `StatTile` had no background and only worked because a white card sat
/// behind it.
class StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String? label;

  const StatChip.stars({super.key, required this.value, this.label})
    : icon = FontAwesomeIcons.solidStar,
      color = AppColors.star;

  const StatChip.streak({super.key, required this.value, this.label})
    : icon = FontAwesomeIcons.fire,
      color = AppColors.streak;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null;
    // Opaque pale version of the stat colour so it composites cleanly over
    // both coloured (dashboard/profile) and white (progress) backgrounds.
    final background = Color.alphaBlend(color.withOpacity(0.14), Colors.white);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: hasLabel ? 12 : 9,
        vertical: hasLabel ? 10 : 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: color, size: hasLabel ? 18 : 15),
          SizedBox(width: hasLabel ? 10 : 6),
          hasLabel
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: AppTextStyles.h3),
                    Text(label!, style: AppTextStyles.bodySmall),
                  ],
                )
              : Text(
                  value,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
        ],
      ),
    );
  }
}
