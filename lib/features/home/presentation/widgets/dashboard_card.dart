import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/dashboard_item.dart';

/// Dashboard menu card widget
class DashboardCard extends StatelessWidget {
  final DashboardItem item;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item.icon,
                    size: 48,
                    color: item.color,
                  ),
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEB5C00), // Naranja corporativo
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${item.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Texts (shrink safely if vertical space is tight)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: item.color,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacingS),

                      // Subtitle
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
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
