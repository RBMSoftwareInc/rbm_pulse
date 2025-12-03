-- Future Me - AI Growth Twin - Database Schema
-- Run this in Supabase SQL Editor

-- Growth metrics snapshot table (stores historical growth data)
CREATE TABLE IF NOT EXISTS public.growth_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  skill_sparks_score NUMERIC(5, 2) DEFAULT 0,
  brain_forge_score NUMERIC(5, 2) DEFAULT 0,
  mind_balance_streak INTEGER DEFAULT 0,
  focus_zone_discipline NUMERIC(5, 2) DEFAULT 0,
  thought_circles_participation NUMERIC(5, 2) DEFAULT 0,
  idea_lab_impact_score NUMERIC(5, 2) DEFAULT 0,
  meeting_room_contribution NUMERIC(5, 2) DEFAULT 0,
  future_growth_rating NUMERIC(5, 2) DEFAULT 0,
  snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, snapshot_date)
);

-- Growth predictions table
CREATE TABLE IF NOT EXISTS public.growth_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_rating NUMERIC(5, 2) NOT NULL,
  predicted_3_months NUMERIC(5, 2),
  predicted_6_months NUMERIC(5, 2),
  predicted_12_months NUMERIC(5, 2),
  motivational_message TEXT,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Weekly challenges table
CREATE TABLE IF NOT EXISTS public.weekly_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('skill', 'wellbeing', 'cognitive', 'innovation', 'collaboration')),
  target_score NUMERIC(5, 2) NOT NULL,
  current_progress NUMERIC(5, 2) DEFAULT 0,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Skill tree nodes table
CREATE TABLE IF NOT EXISTS public.skill_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('skill', 'cognitive', 'wellbeing', 'collaboration')),
  level NUMERIC(5, 2) DEFAULT 0 CHECK (level >= 0 AND level <= 100),
  is_mastered BOOLEAN DEFAULT false,
  mastered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Skill node connections (many-to-many)
CREATE TABLE IF NOT EXISTS public.skill_node_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_node_id UUID NOT NULL REFERENCES public.skill_nodes(id) ON DELETE CASCADE,
  to_node_id UUID NOT NULL REFERENCES public.skill_nodes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(from_node_id, to_node_id)
);

-- Recommended actions table
CREATE TABLE IF NOT EXISTS public.recommended_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action_text TEXT NOT NULL,
  category TEXT,
  priority INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_growth_snapshots_user_id ON public.growth_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_growth_snapshots_date ON public.growth_snapshots(snapshot_date DESC);
CREATE INDEX IF NOT EXISTS idx_growth_predictions_user_id ON public.growth_predictions(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_challenges_user_id ON public.weekly_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_challenges_dates ON public.weekly_challenges(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_skill_nodes_user_id ON public.skill_nodes(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_nodes_category ON public.skill_nodes(category);
CREATE INDEX IF NOT EXISTS idx_recommended_actions_user_id ON public.recommended_actions(user_id);

-- Function to calculate future growth rating
CREATE OR REPLACE FUNCTION calculate_future_growth_rating(
  skill_sparks NUMERIC,
  brain_forge NUMERIC,
  mind_balance_streak INTEGER,
  focus_zone NUMERIC,
  thought_circles NUMERIC,
  idea_lab NUMERIC,
  meeting_room NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
  normalized_streak NUMERIC;
  weighted_score NUMERIC;
BEGIN
  -- Normalize streak to 0-100 (max 30 days = 100)
  normalized_streak := LEAST((mind_balance_streak::NUMERIC / 30.0 * 100.0), 100.0);
  
  -- Weighted calculation
  weighted_score := (
    skill_sparks * 0.20 +
    brain_forge * 0.15 +
    normalized_streak * 0.15 +
    focus_zone * 0.15 +
    thought_circles * 0.10 +
    idea_lab * 0.15 +
    meeting_room * 0.10
  );
  
  RETURN LEAST(GREATEST(weighted_score, 0), 100);
END;
$$ LANGUAGE plpgsql;

-- Function to update growth snapshot
CREATE OR REPLACE FUNCTION update_growth_snapshot()
RETURNS TRIGGER AS $$
BEGIN
  NEW.future_growth_rating := calculate_future_growth_rating(
    NEW.skill_sparks_score,
    NEW.brain_forge_score,
    NEW.mind_balance_streak,
    NEW.focus_zone_discipline,
    NEW.thought_circles_participation,
    NEW.idea_lab_impact_score,
    NEW.meeting_room_contribution
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate growth rating
CREATE TRIGGER trigger_calculate_growth_rating
  BEFORE INSERT OR UPDATE ON public.growth_snapshots
  FOR EACH ROW
  EXECUTE FUNCTION update_growth_snapshot();

-- RLS Policies
ALTER TABLE public.growth_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.growth_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skill_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skill_node_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommended_actions ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can read own growth snapshots" ON public.growth_snapshots
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own growth snapshots" ON public.growth_snapshots
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own growth snapshots" ON public.growth_snapshots
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own predictions" ON public.growth_predictions
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own predictions" ON public.growth_predictions
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own challenges" ON public.weekly_challenges
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own challenges" ON public.weekly_challenges
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own skill nodes" ON public.skill_nodes
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own skill nodes" ON public.skill_nodes
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own connections" ON public.skill_node_connections
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.skill_nodes
      WHERE id = skill_node_connections.from_node_id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage own connections" ON public.skill_node_connections
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.skill_nodes
      WHERE id = skill_node_connections.from_node_id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can read own recommendations" ON public.recommended_actions
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own recommendations" ON public.recommended_actions
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Comments
COMMENT ON TABLE public.growth_snapshots IS 'Historical snapshots of user growth metrics';
COMMENT ON TABLE public.growth_predictions IS 'AI-generated growth predictions and recommendations';
COMMENT ON TABLE public.weekly_challenges IS 'Personalized weekly challenges for growth';
COMMENT ON TABLE public.skill_nodes IS 'Individual skill nodes in the holographic skill tree';
COMMENT ON TABLE public.skill_node_connections IS 'Connections between skill nodes';
COMMENT ON TABLE public.recommended_actions IS 'AI-recommended actions for growth improvement';

