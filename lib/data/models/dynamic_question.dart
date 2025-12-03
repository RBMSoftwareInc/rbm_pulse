import 'survey_scale.dart';
import 'survey_factor.dart' show SurveyFactor, FactorCategory;

class DynamicQuestion {
  final String id;
  final String prompt;
  final SurveyScale? scale;
  final SurveyFactor? factor;
  final double weight;
  final bool reverseScored;
  final int orderIndex;
  final bool isActive;
  final bool isCustom;
  final Map<String, dynamic>? metadata;

  DynamicQuestion({
    required this.id,
    required this.prompt,
    this.scale,
    this.factor,
    this.weight = 1.0,
    this.reverseScored = false,
    this.orderIndex = 0,
    this.isActive = true,
    this.isCustom = false,
    this.metadata,
  });

  factory DynamicQuestion.fromMap(Map<String, dynamic> map) {
    return DynamicQuestion(
      id: map['id'] as String,
      prompt: map['prompt'] as String,
      scale: map['scale_name'] != null
          ? SurveyScale(
              id: map['scale_id'] as String? ?? '',
              name: map['scale_name'] as String,
              code: map['scale_code'] as String? ?? '',
              description: map['scale_description'] as String?,
            )
          : null,
      factor: map['factor_name'] != null ? _parseFactorFromMap(map) : null,
      weight: (map['weight'] as num?)?.toDouble() ?? 1.0,
      reverseScored: (map['reverse_scored'] ?? false) as bool,
      orderIndex: (map['order_index'] ?? 0) as int,
      isActive: (map['is_active'] ?? true) as bool,
      isCustom: (map['is_custom'] ?? false) as bool,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  static SurveyFactor _parseFactorFromMap(Map<String, dynamic> map) {
    return SurveyFactor(
      id: map['factor_id'] as String? ?? '',
      name: map['factor_name'] as String,
      code: map['factor_code'] as String? ?? '',
      description: map['factor_description'] as String?,
      category: _parseCategory(map['factor_category'] as String?),
    );
  }

  static FactorCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'demand':
        return FactorCategory.demand;
      case 'resource':
        return FactorCategory.resource;
      case 'outcome':
        return FactorCategory.outcome;
      default:
        return FactorCategory.resource;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'scale_id': scale?.id,
      'factor_id': factor?.id,
      'weight': weight,
      'reverse_scored': reverseScored,
      'order_index': orderIndex,
      'is_active': isActive,
      'is_custom': isCustom,
      'metadata': metadata,
    };
  }
}
