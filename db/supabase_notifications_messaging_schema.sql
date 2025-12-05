-- Notifications & Messaging System - Database Schema
-- Run this in Supabase SQL Editor

-- Notification Preferences table
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  achievements_enabled BOOLEAN DEFAULT true,
  focus_zen_nudges_enabled BOOLEAN DEFAULT true,
  social_interactions_enabled BOOLEAN DEFAULT true,
  action_reminders_enabled BOOLEAN DEFAULT true,
  ai_coach_enabled BOOLEAN DEFAULT true,
  in_app_enabled BOOLEAN DEFAULT true,
  email_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TIME, -- HH:mm format
  quiet_hours_end TIME, -- HH:mm format
  do_not_disturb_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN (
    'achievementUnlocked',
    'actionAssigned',
    'followUpDue',
    'discussionReply',
    'recognitionReceived',
    'aiCoachNudge',
    'zenBreakPrompt',
    'meetingReminder',
    'culturePostFeatured',
    'weeklyChallengeComplete'
  )),
  priority TEXT NOT NULL CHECK (priority IN ('high', 'normal', 'low')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  action_url TEXT, -- Deep link to relevant screen
  metadata JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  sender_id UUID REFERENCES auth.users(id),
  sender_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Message Threads table
CREATE TABLE IF NOT EXISTS public.message_threads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  context_type TEXT NOT NULL CHECK (context_type IN (
    'meeting_action',
    'idea_lab',
    'thought_circle'
  )),
  context_id UUID NOT NULL, -- ID of the parent entity
  title TEXT,
  description TEXT,
  participant_ids UUID[] NOT NULL, -- Array of user IDs
  participant_names JSONB DEFAULT '{}', -- userId -> name mapping
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id UUID NOT NULL REFERENCES public.message_threads(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  sender_avatar TEXT,
  content TEXT NOT NULL,
  mentions UUID[], -- Array of mentioned user IDs
  attachments JSONB DEFAULT '[]', -- Array of attachment objects
  reactions JSONB DEFAULT '{}', -- userId -> reaction type mapping
  is_edited BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Message Moderation table (for flagging inappropriate content)
CREATE TABLE IF NOT EXISTS public.message_moderation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  flagged_by UUID NOT NULL REFERENCES auth.users(id),
  reason TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notification Rate Limiting table (for spam prevention)
CREATE TABLE IF NOT EXISTS public.notification_rate_limits (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_timestamp TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, notification_timestamp)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_message_threads_context ON public.message_threads(context_type, context_id);
CREATE INDEX IF NOT EXISTS idx_message_threads_participants ON public.message_threads USING GIN(participant_ids);
CREATE INDEX IF NOT EXISTS idx_messages_thread ON public.messages(thread_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_message_moderation_message ON public.message_moderation(message_id);
CREATE INDEX IF NOT EXISTS idx_message_moderation_status ON public.message_moderation(status);
CREATE INDEX IF NOT EXISTS idx_notification_rate_limits_user ON public.notification_rate_limits(user_id, notification_timestamp DESC);

-- Function to clean old rate limit entries (older than 1 hour)
CREATE OR REPLACE FUNCTION clean_old_rate_limits()
RETURNS void AS $$
BEGIN
  DELETE FROM public.notification_rate_limits
  WHERE notification_timestamp < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_notification_preferences_updated_at
  BEFORE UPDATE ON public.notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_message_threads_updated_at
  BEFORE UPDATE ON public.message_threads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_moderation ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_rate_limits ENABLE ROW LEVEL SECURITY;

-- Notification Preferences: Users can only access their own
CREATE POLICY "Users can manage own preferences" ON public.notification_preferences
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Notifications: Users can only access their own
CREATE POLICY "Users can read own notifications" ON public.notifications
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Message Threads: Users can view threads they participate in, or if they have permission
CREATE POLICY "Users can view participating threads" ON public.message_threads
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = ANY(participant_ids)
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

CREATE POLICY "Users can create threads" ON public.message_threads
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = ANY(participant_ids)
  );

-- Messages: Users can view messages in threads they participate in
CREATE POLICY "Users can view thread messages" ON public.messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.message_threads
      WHERE id = messages.thread_id
      AND (
        auth.uid() = ANY(participant_ids)
        OR EXISTS (
          SELECT 1 FROM public.profiles
          WHERE id = auth.uid()
          AND role IN ('hr', 'admin', 'superadmin')
        )
      )
    )
  );

CREATE POLICY "Users can send messages in threads" ON public.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.message_threads
      WHERE id = messages.thread_id
      AND auth.uid() = ANY(participant_ids)
    )
  );

CREATE POLICY "Users can update own messages" ON public.messages
  FOR UPDATE
  TO authenticated
  USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- Message Moderation: HR/Admin can view and manage
CREATE POLICY "HR and admins can moderate messages" ON public.message_moderation
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('hr', 'admin', 'superadmin')
    )
  );

-- Notification Rate Limits: Users can only see their own
CREATE POLICY "Users can see own rate limits" ON public.notification_rate_limits
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Comments
COMMENT ON TABLE public.notification_preferences IS 'User notification preferences and settings';
COMMENT ON TABLE public.notifications IS 'In-app notifications for users';
COMMENT ON TABLE public.message_threads IS 'Message threads for context-based conversations';
COMMENT ON TABLE public.messages IS 'Individual messages within threads';
COMMENT ON TABLE public.message_moderation IS 'Flagged messages for moderation';
COMMENT ON TABLE public.notification_rate_limits IS 'Rate limiting for notification spam prevention';

