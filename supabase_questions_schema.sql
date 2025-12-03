-- Comprehensive Database Schema for Dynamic Survey System
-- Run this in Supabase SQL Editor after the pulses migration

-- ============================================
-- SCIENTIFIC SCALES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.survey_scales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  code TEXT NOT NULL UNIQUE, -- e.g., 'GALLUP_Q12', 'UWES', 'PHQ2'
  description TEXT,
  source TEXT, -- e.g., 'Gallup', 'Utrecht University', 'WHO'
  version TEXT DEFAULT '1.0',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- ============================================
-- SURVEY FACTORS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.survey_factors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  code TEXT NOT NULL UNIQUE, -- e.g., 'AUTONOMY', 'WORKLOAD_PRESSURE'
  description TEXT,
  category TEXT, -- 'demand', 'resource', 'outcome'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- QUESTIONS TABLE (750+ questions)
-- ============================================
CREATE TABLE IF NOT EXISTS public.survey_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prompt TEXT NOT NULL,
  scale_id UUID REFERENCES public.survey_scales(id) ON DELETE SET NULL,
  factor_id UUID REFERENCES public.survey_factors(id) ON DELETE SET NULL,
  weight NUMERIC(3, 2) DEFAULT 1.0, -- Question importance weight
  reverse_scored BOOLEAN DEFAULT false,
  order_index INTEGER DEFAULT 0, -- For ordering within scale/factor
  is_active BOOLEAN DEFAULT true,
  is_custom BOOLEAN DEFAULT false, -- HR-created custom questions
  created_by UUID REFERENCES auth.users(id), -- HR/admin who created
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB -- Additional question metadata (tags, context, etc.)
);

-- ============================================
-- QUESTION BANKS (Groupings for surveys)
-- ============================================
CREATE TABLE IF NOT EXISTS public.question_banks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- ============================================
-- QUESTION BANK MEMBERSHIP
-- ============================================
CREATE TABLE IF NOT EXISTS public.question_bank_questions (
  bank_id UUID REFERENCES public.question_banks(id) ON DELETE CASCADE,
  question_id UUID REFERENCES public.survey_questions(id) ON DELETE CASCADE,
  order_index INTEGER DEFAULT 0,
  PRIMARY KEY (bank_id, question_id)
);

-- ============================================
-- ACTIVE SURVEY CONFIGURATIONS
-- ============================================
CREATE TABLE IF NOT EXISTS public.survey_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  question_bank_id UUID REFERENCES public.question_banks(id),
  max_questions INTEGER DEFAULT 5, -- How many questions to show per check-in
  randomize BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- ============================================
-- AI RESPONSE GENERATION RULES
-- ============================================
CREATE TABLE IF NOT EXISTS public.response_generation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  rule_type TEXT NOT NULL, -- 'ai_prompt', 'custom_logic', 'template'
  condition JSONB, -- When to apply this rule (e.g., burnout > 70)
  action JSONB, -- What to generate (prompt, template, etc.)
  priority INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_questions_scale ON public.survey_questions(scale_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_questions_factor ON public.survey_questions(factor_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_questions_active ON public.survey_questions(is_active, order_index);
CREATE INDEX IF NOT EXISTS idx_questions_custom ON public.survey_questions(is_custom, created_by);
CREATE INDEX IF NOT EXISTS idx_bank_questions ON public.question_bank_questions(bank_id, order_index);
CREATE INDEX IF NOT EXISTS idx_config_active ON public.survey_configurations(is_active, valid_from, valid_until);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.survey_scales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_factors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_bank_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.response_generation_rules ENABLE ROW LEVEL SECURITY;

-- Everyone can read active scales, factors, questions
CREATE POLICY "Anyone can read active scales" ON public.survey_scales
  FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can read active factors" ON public.survey_factors
  FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can read active questions" ON public.survey_questions
  FOR SELECT USING (is_active = true);

-- Only admins/HR can modify
CREATE POLICY "Admins can manage scales" ON public.survey_scales
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "Admins can manage factors" ON public.survey_factors
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "HR can manage questions" ON public.survey_questions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'hr')
    )
  );

-- HR can create custom questions
CREATE POLICY "HR can create custom questions" ON public.survey_questions
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'hr')
    )
    AND is_custom = true
  );

-- ============================================
-- INITIAL DATA: SCIENTIFIC SCALES
-- ============================================
INSERT INTO public.survey_scales (name, code, description, source) VALUES
  ('Gallup Q12', 'GALLUP_Q12', '12-item employee engagement survey', 'Gallup'),
  ('Utrecht Work Engagement Scale', 'UWES', 'Measures work engagement across vigor, dedication, absorption', 'Utrecht University'),
  ('Patient Health Questionnaire-2', 'PHQ2', 'Brief depression screening tool', 'WHO'),
  ('Inclusion Index', 'INCLUSION', 'Measures sense of belonging and inclusion', 'Custom'),
  ('Job Demands-Resources Model', 'JD_R', 'Assesses job demands vs resources', 'Bakker & Demerouti')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- INITIAL DATA: SURVEY FACTORS
-- ============================================
INSERT INTO public.survey_factors (name, code, description, category) VALUES
  ('Autonomy', 'AUTONOMY', 'Decision-making latitude and control', 'resource'),
  ('Workload Pressure', 'WORKLOAD_PRESSURE', 'Perceived work demands and time pressure', 'demand'),
  ('Social Support', 'SOCIAL_SUPPORT', 'Support from peers and colleagues', 'resource'),
  ('Feedback Quality', 'FEEDBACK_QUALITY', 'Timeliness and constructiveness of feedback', 'resource'),
  ('Sense of Belonging', 'BELONGING', 'Feeling included and valued in the team', 'outcome'),
  ('Work-Life Balance', 'WORK_LIFE_BALANCE', 'Balance between work and personal life', 'resource'),
  ('Recognition', 'RECOGNITION', 'Acknowledgment of contributions', 'resource'),
  ('Growth Opportunities', 'GROWTH', 'Learning and development prospects', 'resource')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- SAMPLE QUESTIONS (You can add 750+ more)
-- ============================================
-- Note: In production, you'd bulk import 750+ questions
-- This is just a sample structure

INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index)
SELECT 
  q.prompt,
  s.id as scale_id,
  f.id as factor_id,
  q.weight,
  q.reverse_scored,
  q.order_index
FROM (VALUES
  ('How included do you feel in recent team decisions?', 'GALLUP_Q12', 'AUTONOMY', 1.0, false, 1),
  ('How much pressure do current release deadlines put on your wellbeing?', 'JD_R', 'WORKLOAD_PRESSURE', 1.2, false, 2),
  ('How often do you turn to peers for help on tasks?', 'INCLUSION', 'SOCIAL_SUPPORT', 1.0, false, 3),
  ('Do you receive timely, constructive feedback from your manager?', 'GALLUP_Q12', 'FEEDBACK_QUALITY', 1.1, false, 4),
  ('Have you felt isolated due to remote/hybrid work?', 'INCLUSION', 'BELONGING', 1.0, true, 5)
) AS q(prompt, scale_code, factor_code, weight, reverse_scored, order_index)
JOIN public.survey_scales s ON s.code = q.scale_code
JOIN public.survey_factors f ON f.code = q.factor_code
ON CONFLICT DO NOTHING;

-- ============================================
-- FUNCTIONS FOR DYNAMIC QUESTION SELECTION
-- ============================================
CREATE OR REPLACE FUNCTION public.get_active_questions(
  config_id UUID DEFAULT NULL,
  limit_count INTEGER DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  prompt TEXT,
  scale_name TEXT,
  factor_name TEXT,
  weight NUMERIC,
  reverse_scored BOOLEAN,
  order_index INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    q.id,
    q.prompt,
    s.name as scale_name,
    f.name as factor_name,
    q.weight,
    q.reverse_scored,
    q.order_index
  FROM public.survey_questions q
  LEFT JOIN public.survey_scales s ON s.id = q.scale_id
  LEFT JOIN public.survey_factors f ON f.id = q.factor_id
  WHERE q.is_active = true
  ORDER BY 
    CASE WHEN config_id IS NOT NULL THEN 
      (SELECT order_index FROM public.question_bank_questions 
       WHERE bank_id = (SELECT question_bank_id FROM public.survey_configurations WHERE id = config_id)
       AND question_id = q.id)
    ELSE q.order_index END,
    RANDOM()
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

