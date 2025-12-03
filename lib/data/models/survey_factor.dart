enum FactorCategory { demand, resource, outcome }

class SurveyFactor {
  final String id;
  final String name;
  final String code;
  final String? description;
  final FactorCategory category;
  final bool isActive;

  SurveyFactor({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.category,
    this.isActive = true,
  });

  factory SurveyFactor.fromMap(Map<String, dynamic> map) {
    return SurveyFactor(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      description: map['description'] as String?,
      category: _parseCategory(map['category'] as String?),
      isActive: (map['is_active'] ?? true) as bool,
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
      'name': name,
      'code': code,
      'description': description,
      'category': category.name,
      'is_active': isActive,
    };
  }
}
