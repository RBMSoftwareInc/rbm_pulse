-- Migration: Add missing columns to pulses table for scientific survey features
-- Run this in Supabase SQL Editor: Database -> SQL Editor

-- Add response_time_ms (time taken to complete check-in in milliseconds)
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS response_time_ms INTEGER;

-- Add attention_check_passed (validates user engagement quality)
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS attention_check_passed BOOLEAN DEFAULT false;

-- Add burnout_risk_score (computed scientific burnout metric 0-100)
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS burnout_risk_score NUMERIC(5, 2);

-- Add engagement_score (computed engagement metric 0-100)
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS engagement_score NUMERIC(5, 2);

-- Add question_payload (stores individual question responses as JSONB)
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS question_payload JSONB;

-- Add factor_scores (stores factor-level scores as JSONB, e.g., {"autonomy": 75.5, "workloadPressure": 42.3})
ALTER TABLE public.pulses
  ADD COLUMN IF NOT EXISTS factor_scores JSONB;

-- Optional: Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_pulses_burnout_risk ON public.pulses(burnout_risk_score) WHERE burnout_risk_score IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pulses_engagement ON public.pulses(engagement_score) WHERE engagement_score IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pulses_attention_check ON public.pulses(attention_check_passed) WHERE attention_check_passed = false;
CREATE INDEX IF NOT EXISTS idx_pulses_created_at ON public.pulses(created_at DESC);

-- Optional: Add comments for documentation
COMMENT ON COLUMN public.pulses.response_time_ms IS 'Time taken to complete the check-in in milliseconds';
COMMENT ON COLUMN public.pulses.attention_check_passed IS 'Quality check: true if user spent adequate time and showed engagement';
COMMENT ON COLUMN public.pulses.burnout_risk_score IS 'Computed burnout risk (0-100) using validated scientific scales';
COMMENT ON COLUMN public.pulses.engagement_score IS 'Computed engagement score (0-100) using validated scientific scales';
COMMENT ON COLUMN public.pulses.question_payload IS 'Individual question responses with color, valence, energy, notes per question';
COMMENT ON COLUMN public.pulses.factor_scores IS 'Factor-level scores (autonomy, workloadPressure, socialSupport, etc.) as JSON object';

