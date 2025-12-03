class SurveyScale {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? source;
  final String version;
  final bool isActive;

  SurveyScale({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.source,
    this.version = '1.0',
    this.isActive = true,
  });

  factory SurveyScale.fromMap(Map<String, dynamic> map) {
    return SurveyScale(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      description: map['description'] as String?,
      source: map['source'] as String?,
      version: (map['version'] ?? '1.0') as String,
      isActive: (map['is_active'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'source': source,
      'version': version,
      'is_active': isActive,
    };
  }
}
