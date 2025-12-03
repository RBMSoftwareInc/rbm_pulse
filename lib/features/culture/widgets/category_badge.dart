import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _getCategoryInfo(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryInfo['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryInfo['color'].withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryInfo['icon'],
            size: 14,
            color: categoryInfo['color'],
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: categoryInfo['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String category) {
    switch (category) {
      case 'Achievements':
        return {
          'icon': Icons.emoji_events_rounded,
          'color': Colors.amber,
        };
      case 'Appreciation':
        return {
          'icon': Icons.favorite_rounded,
          'color': Colors.pink,
        };
      case 'Innovation Wins':
        return {
          'icon': Icons.lightbulb_rounded,
          'color': Colors.orange,
        };
      case 'Team Success':
        return {
          'icon': Icons.groups_rounded,
          'color': Colors.blue,
        };
      case 'Culture Values':
        return {
          'icon': Icons.psychology_rounded,
          'color': Colors.purple,
        };
      default:
        return {
          'icon': Icons.category_rounded,
          'color': Colors.grey,
        };
    }
  }
}
