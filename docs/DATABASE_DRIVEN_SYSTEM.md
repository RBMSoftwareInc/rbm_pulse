# Database-Driven Survey System

## Overview
The RBM-Pulse app now supports a fully database-driven survey system with:
- **750+ questions** stored in Supabase
- **Dynamic question loading** from database
- **HR/Admin control** to add custom questions
- **AI/Programmatic response generation**
- **Scientific scales and factors** managed in database

## Database Schema

### Tables Created
1. **survey_scales** - Scientific scales (Gallup Q12, UWES, PHQ2, etc.)
2. **survey_factors** - Survey factors (Autonomy, Workload Pressure, etc.)
3. **survey_questions** - All questions (750+)
4. **question_banks** - Groupings of questions
5. **question_bank_questions** - Membership table
6. **survey_configurations** - Active survey configs
7. **response_generation_rules** - AI/response generation rules

## Setup Instructions

### 1. Run Database Migrations
```sql
-- First run: db/supabase_migration.sql (for pulses table)
-- Then run: db/supabase_questions_schema.sql (for questions system)
```

### 2. Import 750+ Questions
You'll need to bulk import questions. Example format:
```sql
INSERT INTO survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index)
VALUES 
  ('Question 1...', 'scale-uuid', 'factor-uuid', 1.0, false, 1),
  ('Question 2...', 'scale-uuid', 'factor-uuid', 1.0, false, 2),
  -- ... 750+ more questions
```

### 3. Update Check-in Flow
The `SequentialCheckinScreen` needs to be updated to:
- Load questions from `QuestionRepository.getActiveQuestions()`
- Use `DynamicQuestion` model instead of hardcoded `ScientificQuestion`
- Map database questions to the existing UI

## Key Files Created

### Models
- `lib/data/models/survey_scale.dart` - Scale model
- `lib/data/models/survey_factor.dart` - Factor model  
- `lib/data/models/dynamic_question.dart` - Dynamic question model

### Repositories
- `lib/data/repositories/question_repository.dart` - Question CRUD operations

### Providers
- Updated `lib/state/app_providers.dart` with `questionRepoProvider`

## Next Steps

### 1. Update Check-in Screen
Modify `sequential_checkin_screen.dart` to:
```dart
// Replace hardcoded scientificQuestionBank with:
final questions = await ref.read(questionRepoProvider).getActiveQuestions(limit: 5);
```

### 2. Create Admin Screens
- Question management screen
- Scale/factor management
- Survey configuration screen
- Response generation rules editor

### 3. AI Integration
- Connect to OpenAI/Claude API for response generation
- Use `response_generation_rules` table to configure prompts
- Generate personalized recommendations based on responses

### 4. HR Custom Questions
- UI for HR to add custom questions
- Validation and approval workflow
- Integration with existing scoring system

## Color Wheel Fix
✅ Fixed angle calculation - now correctly selects the tapped color segment

## Navigation Fix  
✅ Fixed "Go Home" button - now properly navigates back to main screen

## Current Status
- ✅ Database schema created
- ✅ Models and repositories created
- ✅ Navigation fixed
- ✅ Color wheel fixed
- ⏳ Check-in screen needs update to use dynamic questions
- ⏳ Admin screens need to be built
- ⏳ AI integration needs implementation

