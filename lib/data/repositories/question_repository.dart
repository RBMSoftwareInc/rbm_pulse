import '../supabase_client.dart';
import '../models/dynamic_question.dart';
import '../models/survey_scale.dart';
import '../models/survey_factor.dart';

class QuestionRepository {
  final _table = 'survey_questions';
  final _scalesTable = 'survey_scales';
  final _factorsTable = 'survey_factors';

  /// Fetch active questions for a check-in session
  /// Uses the get_active_questions function if configId is provided,
  /// otherwise fetches directly from questions table
  Future<List<DynamicQuestion>> getActiveQuestions({
    String? configId,
    int limit = 5,
  }) async {
    try {
      List<Map<String, dynamic>> results;

      if (configId != null) {
        // Use the database function for configured surveys
        final response = await supabase.rpc(
          'get_active_questions',
          params: {
            'config_id': configId,
            'limit_count': limit,
          },
        );
        results = (response as List).cast<Map<String, dynamic>>();
      } else {
        // Direct query for active questions
        results = await supabase.from(_table).select('''
              id,
              prompt,
              weight,
              reverse_scored,
              order_index,
              is_active,
              is_custom,
              metadata,
              survey_scales!inner(id, name, code, description),
              survey_factors!inner(id, name, code, description, category)
            ''').eq('is_active', true).order('order_index').limit(limit);
      }

      return results.map((row) {
        // Transform the joined data into DynamicQuestion format
        final scaleData = row['survey_scales'] as Map<String, dynamic>?;
        final factorData = row['survey_factors'] as Map<String, dynamic>?;

        return DynamicQuestion(
          id: row['id'] as String,
          prompt: row['prompt'] as String,
          scale: scaleData != null ? SurveyScale.fromMap(scaleData) : null,
          factor: factorData != null ? SurveyFactor.fromMap(factorData) : null,
          weight: (row['weight'] as num?)?.toDouble() ?? 1.0,
          reverseScored: (row['reverse_scored'] ?? false) as bool,
          orderIndex: (row['order_index'] ?? 0) as int,
          isActive: (row['is_active'] ?? true) as bool,
          isCustom: (row['is_custom'] ?? false) as bool,
          metadata: row['metadata'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  /// Get all active scales
  Future<List<SurveyScale>> getActiveScales() async {
    final results = await supabase
        .from(_scalesTable)
        .select()
        .eq('is_active', true)
        .order('name');

    return (results as List)
        .map((row) => SurveyScale.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Get all active factors
  Future<List<SurveyFactor>> getActiveFactors() async {
    final results = await supabase
        .from(_factorsTable)
        .select()
        .eq('is_active', true)
        .order('name');

    return (results as List)
        .map((row) => SurveyFactor.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Create a custom question (HR/admin only)
  Future<DynamicQuestion> createCustomQuestion({
    required String prompt,
    String? scaleId,
    String? factorId,
    double weight = 1.0,
    bool reverseScored = false,
    Map<String, dynamic>? metadata,
  }) async {
    final result = await supabase
        .from(_table)
        .insert({
          'prompt': prompt,
          'scale_id': scaleId,
          'factor_id': factorId,
          'weight': weight,
          'reverse_scored': reverseScored,
          'is_custom': true,
          'is_active': true,
          'metadata': metadata,
        })
        .select()
        .single();

    return DynamicQuestion.fromMap(result);
  }

  /// Update a question
  Future<void> updateQuestion(
      String questionId, Map<String, dynamic> updates) async {
    await supabase.from(_table).update({
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', questionId);
  }

  /// Deactivate a question (soft delete)
  Future<void> deactivateQuestion(String questionId) async {
    await supabase.from(_table).update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', questionId);
  }
}
