-- Meeting Room - Database Schema
-- Run this in Supabase SQL Editor

-- Meetings table
CREATE TABLE IF NOT EXISTS public.meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  participant_ids UUID[] NOT NULL DEFAULT '{}',
  participant_names TEXT[] NOT NULL DEFAULT '{}',
  organizer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organizer_name TEXT NOT NULL,
  access_level TEXT NOT NULL CHECK (access_level IN ('private', 'team', 'org_library')) DEFAULT 'private',
  audio_record_id UUID,
  summary_id UUID,
  is_recorded BOOLEAN DEFAULT false,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audio records table
CREATE TABLE IF NOT EXISTS public.audio_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
  file_url TEXT,
  file_path TEXT,
  file_size_bytes INTEGER,
  duration_ms INTEGER,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  transcript TEXT -- Placeholder for AI-generated transcript
);

-- Meeting summaries table
CREATE TABLE IF NOT EXISTS public.meeting_summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
  key_decisions TEXT[] DEFAULT '{}',
  risks TEXT[] DEFAULT '{}',
  open_questions TEXT[] DEFAULT '{}',
  notes TEXT,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Action items table
CREATE TABLE IF NOT EXISTS public.action_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
  summary_id UUID NOT NULL REFERENCES public.meeting_summaries(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  assigned_to_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  assigned_to_name TEXT NOT NULL,
  due_date TIMESTAMPTZ,
  status TEXT NOT NULL CHECK (status IN ('pending', 'in_progress', 'done')) DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_meetings_scheduled_at ON public.meetings(scheduled_at DESC);
CREATE INDEX IF NOT EXISTS idx_meetings_organizer_id ON public.meetings(organizer_id);
CREATE INDEX IF NOT EXISTS idx_meetings_access_level ON public.meetings(access_level);
CREATE INDEX IF NOT EXISTS idx_audio_records_meeting_id ON public.audio_records(meeting_id);
CREATE INDEX IF NOT EXISTS idx_meeting_summaries_meeting_id ON public.meeting_summaries(meeting_id);
CREATE INDEX IF NOT EXISTS idx_action_items_meeting_id ON public.action_items(meeting_id);
CREATE INDEX IF NOT EXISTS idx_action_items_assigned_to_id ON public.action_items(assigned_to_id);
CREATE INDEX IF NOT EXISTS idx_action_items_status ON public.action_items(status);
CREATE INDEX IF NOT EXISTS idx_action_items_due_date ON public.action_items(due_date);

-- Function to update meeting updated_at timestamp
CREATE OR REPLACE FUNCTION update_meeting_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER trigger_update_meeting_updated_at
  BEFORE UPDATE ON public.meetings
  FOR EACH ROW
  EXECUTE FUNCTION update_meeting_updated_at();

-- Function to update summary updated_at timestamp
CREATE OR REPLACE FUNCTION update_summary_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update summary updated_at
CREATE TRIGGER trigger_update_summary_updated_at
  BEFORE UPDATE ON public.meeting_summaries
  FOR EACH ROW
  EXECUTE FUNCTION update_summary_updated_at();

-- RLS Policies
ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audio_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.action_items ENABLE ROW LEVEL SECURITY;

-- Meetings: Users can read meetings they have access to
CREATE POLICY "Users can read accessible meetings" ON public.meetings
  FOR SELECT
  TO authenticated
  USING (
    -- Private: user is participant or organizer
    (access_level = 'private' AND (organizer_id = auth.uid() OR auth.uid() = ANY(participant_ids)))
    OR
    -- Team: user is in the team (simplified - in real app, check team membership)
    (access_level = 'team')
    OR
    -- Org Library: all authenticated users (leader approval handled in app logic)
    (access_level = 'org_library')
  );

-- Meetings: Users can create meetings
CREATE POLICY "Users can create meetings" ON public.meetings
  FOR INSERT
  TO authenticated
  WITH CHECK (organizer_id = auth.uid());

-- Meetings: Organizers can update their meetings
CREATE POLICY "Organizers can update meetings" ON public.meetings
  FOR UPDATE
  TO authenticated
  USING (organizer_id = auth.uid())
  WITH CHECK (organizer_id = auth.uid());

-- Meetings: Organizers can delete their meetings
CREATE POLICY "Organizers can delete meetings" ON public.meetings
  FOR DELETE
  TO authenticated
  USING (organizer_id = auth.uid());

-- Audio Records: Users can read records for accessible meetings
CREATE POLICY "Users can read accessible audio records" ON public.audio_records
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = audio_records.meeting_id
      AND (
        (access_level = 'private' AND (organizer_id = auth.uid() OR auth.uid() = ANY(participant_ids)))
        OR access_level IN ('team', 'org_library')
      )
    )
  );

-- Audio Records: Organizers can create records
CREATE POLICY "Organizers can create audio records" ON public.audio_records
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = audio_records.meeting_id
      AND organizer_id = auth.uid()
    )
  );

-- Summaries: Users can read summaries for accessible meetings
CREATE POLICY "Users can read accessible summaries" ON public.meeting_summaries
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = meeting_summaries.meeting_id
      AND (
        (access_level = 'private' AND (organizer_id = auth.uid() OR auth.uid() = ANY(participant_ids)))
        OR access_level IN ('team', 'org_library')
      )
    )
  );

-- Summaries: Organizers can create/update summaries
CREATE POLICY "Organizers can manage summaries" ON public.meeting_summaries
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = meeting_summaries.meeting_id
      AND organizer_id = auth.uid()
    )
  );

-- Action Items: Users can read items for accessible meetings
CREATE POLICY "Users can read accessible action items" ON public.action_items
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = action_items.meeting_id
      AND (
        (access_level = 'private' AND (organizer_id = auth.uid() OR auth.uid() = ANY(participant_ids)))
        OR access_level IN ('team', 'org_library')
      )
    )
  );

-- Action Items: Organizers can create items
CREATE POLICY "Organizers can create action items" ON public.action_items
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.meetings
      WHERE id = action_items.meeting_id
      AND organizer_id = auth.uid()
    )
  );

-- Action Items: Assigned users can update their items
CREATE POLICY "Assigned users can update action items" ON public.action_items
  FOR UPDATE
  TO authenticated
  USING (assigned_to_id = auth.uid())
  WITH CHECK (assigned_to_id = auth.uid());

-- Comments for documentation
COMMENT ON TABLE public.meetings IS 'Stores meeting information with access control';
COMMENT ON TABLE public.audio_records IS 'Stores audio recording metadata and transcripts';
COMMENT ON TABLE public.meeting_summaries IS 'AI-generated meeting summaries with key decisions, risks, and questions';
COMMENT ON TABLE public.action_items IS 'Action items extracted from meetings with assignments and due dates';

