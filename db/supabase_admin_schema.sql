-- Admin & Leadership Control - Database Schema
-- Run this in Supabase SQL Editor

-- Organizations table (for multi-tenant support)
CREATE TABLE IF NOT EXISTS public.organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  domain TEXT,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Teams table
CREATE TABLE IF NOT EXISTS public.teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  department TEXT,
  location TEXT,
  manager_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Update profiles to include team_id
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS team_id UUID REFERENCES public.teams(id);

-- AI Settings table
CREATE TABLE IF NOT EXISTS public.ai_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  setting_key TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('content', 'scoring', 'recommendations', 'filters')),
  value JSONB NOT NULL,
  description TEXT,
  is_editable BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, setting_key)
);

-- Meeting Metrics table
CREATE TABLE IF NOT EXISTS public.meeting_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
  total_meetings INTEGER DEFAULT 0,
  avg_duration_minutes NUMERIC(5, 2) DEFAULT 0,
  action_items_completed INTEGER DEFAULT 0,
  action_items_pending INTEGER DEFAULT 0,
  productivity_score NUMERIC(5, 2) DEFAULT 0,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(team_id, period_start, period_end)
);

-- Culture Metrics table
CREATE TABLE IF NOT EXISTS public.culture_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  health_score NUMERIC(5, 2) DEFAULT 0,
  total_posts INTEGER DEFAULT 0,
  positive_reactions INTEGER DEFAULT 0,
  engagement_rate NUMERIC(5, 2) DEFAULT 0,
  metric_date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, metric_date)
);

-- Employee Focus Data table
CREATE TABLE IF NOT EXISTS public.employee_focus_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  focus_consistency NUMERIC(5, 2) DEFAULT 0,
  focus_sessions_completed INTEGER DEFAULT 0,
  avg_session_duration_minutes NUMERIC(5, 2) DEFAULT 0,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, period_start, period_end)
);

-- Burnout Risk Data table
CREATE TABLE IF NOT EXISTS public.burnout_risk_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  burnout_risk_score NUMERIC(5, 2) DEFAULT 0,
  engagement_score NUMERIC(5, 2) DEFAULT 0,
  risk_level TEXT CHECK (risk_level IN ('low', 'moderate', 'high', 'critical')),
  intervention_suggested BOOLEAN DEFAULT false,
  intervention_applied BOOLEAN DEFAULT false,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Badge Awards table
CREATE TABLE IF NOT EXISTS public.badge_awards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_type TEXT NOT NULL,
  badge_name TEXT NOT NULL,
  category TEXT CHECK (category IN ('skills', 'ideas', 'wellness', 'meetings', 'innovation')),
  awarded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  awarded_by UUID REFERENCES auth.users(id),
  metadata JSONB DEFAULT '{}'
);

-- Audit Logs table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  details JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Admin Alerts table
CREATE TABLE IF NOT EXISTS public.admin_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  alert_type TEXT NOT NULL CHECK (alert_type IN ('burnout', 'stress', 'meeting_overload', 'low_engagement', 'system')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
  user_id UUID REFERENCES auth.users(id),
  team_id UUID REFERENCES public.teams(id),
  is_resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Post Moderation Queue table
CREATE TABLE IF NOT EXISTS public.post_moderation_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.culture_posts(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'flagged')),
  flagged_reason TEXT,
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Update culture_posts to include featured flag
ALTER TABLE public.culture_posts
  ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS featured_until TIMESTAMPTZ;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_teams_organization ON public.teams(organization_id);
CREATE INDEX IF NOT EXISTS idx_teams_manager ON public.teams(manager_id);
CREATE INDEX IF NOT EXISTS idx_profiles_team ON public.profiles(team_id);
CREATE INDEX IF NOT EXISTS idx_ai_settings_org ON public.ai_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_meeting_metrics_team ON public.meeting_metrics(team_id);
CREATE INDEX IF NOT EXISTS idx_culture_metrics_org ON public.culture_metrics(organization_id);
CREATE INDEX IF NOT EXISTS idx_culture_metrics_date ON public.culture_metrics(metric_date DESC);
CREATE INDEX IF NOT EXISTS idx_focus_data_user ON public.employee_focus_data(user_id);
CREATE INDEX IF NOT EXISTS idx_burnout_risk_user ON public.burnout_risk_data(user_id);
CREATE INDEX IF NOT EXISTS idx_burnout_risk_date ON public.burnout_risk_data(recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_badge_awards_user ON public.badge_awards(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_alerts_org ON public.admin_alerts(organization_id);
CREATE INDEX IF NOT EXISTS idx_admin_alerts_resolved ON public.admin_alerts(is_resolved, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_post_moderation_post ON public.post_moderation_queue(post_id);
CREATE INDEX IF NOT EXISTS idx_post_moderation_status ON public.post_moderation_queue(status);

-- RLS Policies
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.culture_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_focus_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.burnout_risk_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_awards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_moderation_queue ENABLE ROW LEVEL SECURITY;

-- Organizations: Admins can read all, others read own org
CREATE POLICY "Admins can read all organizations" ON public.organizations
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'superadmin')
    )
  );

-- Teams: Team leads can read their team, HR/Admin can read all
CREATE POLICY "Team leads can read own team" ON public.teams
  FOR SELECT
  TO authenticated
  USING (
    manager_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- AI Settings: Only admins can manage
CREATE POLICY "Admins can manage AI settings" ON public.ai_settings
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'superadmin')
    )
  );

-- Meeting Metrics: Team leads see their team, HR/Admin see all
CREATE POLICY "Team leads see own team metrics" ON public.meeting_metrics
  FOR SELECT
  TO authenticated
  USING (
    team_id IN (
      SELECT id FROM public.teams WHERE manager_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Culture Metrics: All authenticated users can read
CREATE POLICY "Authenticated users can read culture metrics" ON public.culture_metrics
  FOR SELECT
  TO authenticated
  USING (true);

-- Employee Focus Data: Users see own, HR/Admin see all
CREATE POLICY "Users see own focus data" ON public.employee_focus_data
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Burnout Risk Data: Users see own, HR/Admin see all
CREATE POLICY "Users see own burnout data" ON public.burnout_risk_data
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Badge Awards: All can read
CREATE POLICY "All can read badge awards" ON public.badge_awards
  FOR SELECT
  TO authenticated
  USING (true);

-- Audit Logs: Only admins can read
CREATE POLICY "Admins can read audit logs" ON public.audit_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'superadmin')
    )
  );

-- Admin Alerts: HR/Admin can read
CREATE POLICY "HR and admins can read alerts" ON public.admin_alerts
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Post Moderation: HR/Admin can manage
CREATE POLICY "HR and admins can moderate posts" ON public.post_moderation_queue
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Comments
COMMENT ON TABLE public.organizations IS 'Multi-tenant organization support';
COMMENT ON TABLE public.teams IS 'Organizational teams and departments';
COMMENT ON TABLE public.ai_settings IS 'AI configuration and rules';
COMMENT ON TABLE public.meeting_metrics IS 'Team-level meeting productivity metrics';
COMMENT ON TABLE public.culture_metrics IS 'Organization culture health metrics';
COMMENT ON TABLE public.employee_focus_data IS 'Employee focus zone activity data';
COMMENT ON TABLE public.burnout_risk_data IS 'Employee burnout risk assessments';
COMMENT ON TABLE public.badge_awards IS 'Gamification badge awards';
COMMENT ON TABLE public.audit_logs IS 'System audit trail for accountability';
COMMENT ON TABLE public.admin_alerts IS 'Admin alerts and notifications';
COMMENT ON TABLE public.post_moderation_queue IS 'Culture post moderation workflow';

