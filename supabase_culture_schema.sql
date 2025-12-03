-- Inside RBM Culture Engine - Database Schema
-- Run this in Supabase SQL Editor

-- Posts table
CREATE TABLE IF NOT EXISTS public.culture_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('Achievements', 'Appreciation', 'Innovation Wins', 'Team Success', 'Culture Values')),
  media_url TEXT,
  media_type TEXT CHECK (media_type IN ('image', 'video')),
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_by_name TEXT NOT NULL,
  created_by_avatar TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_featured BOOLEAN DEFAULT false,
  is_hero BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  reactions JSONB DEFAULT '{}'::jsonb, -- Stores reaction counts: {"helpful": 5, "innovative": 3, ...}
  comment_count INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reactions table (tracks individual user reactions)
CREATE TABLE IF NOT EXISTS public.post_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.culture_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('helpful', 'innovative', 'inspiring', 'team_spirit', 'growth')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, user_id, reaction_type) -- One reaction type per user per post
);

-- Comments table
CREATE TABLE IF NOT EXISTS public.post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.culture_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_avatar TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_culture_posts_created_at ON public.culture_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_culture_posts_category ON public.culture_posts(category);
CREATE INDEX IF NOT EXISTS idx_culture_posts_featured ON public.culture_posts(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_culture_posts_hero ON public.culture_posts(is_hero) WHERE is_hero = true;
CREATE INDEX IF NOT EXISTS idx_post_reactions_post_id ON public.post_reactions(post_id);
CREATE INDEX IF NOT EXISTS idx_post_reactions_user_id ON public.post_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_post_id ON public.post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_created_at ON public.post_comments(created_at DESC);

-- Function to update reaction counts
CREATE OR REPLACE FUNCTION update_post_reaction_counts()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.culture_posts
  SET reactions = (
    SELECT jsonb_object_agg(reaction_type, count)
    FROM (
      SELECT reaction_type, COUNT(*) as count
      FROM public.post_reactions
      WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
      GROUP BY reaction_type
    ) sub
  )
  WHERE id = COALESCE(NEW.post_id, OLD.post_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update reaction counts
CREATE TRIGGER trigger_update_reaction_counts
  AFTER INSERT OR DELETE ON public.post_reactions
  FOR EACH ROW
  EXECUTE FUNCTION update_post_reaction_counts();

-- Function to update comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.culture_posts
  SET comment_count = (
    SELECT COUNT(*)
    FROM public.post_comments
    WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
      AND is_deleted = false
  )
  WHERE id = COALESCE(NEW.post_id, OLD.post_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update comment count
CREATE TRIGGER trigger_update_comment_count
  AFTER INSERT OR DELETE OR UPDATE ON public.post_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_post_comment_count();

-- RLS Policies
ALTER TABLE public.culture_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;

-- Anyone can read posts (non-deleted)
CREATE POLICY "Anyone can read posts" ON public.culture_posts
  FOR SELECT
  USING (is_deleted = false);

-- Authenticated users can create posts
CREATE POLICY "Users can create posts" ON public.culture_posts
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Users can update their own posts
CREATE POLICY "Users can update own posts" ON public.culture_posts
  FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- Admins/HR can delete any post
CREATE POLICY "Admins can delete posts" ON public.culture_posts
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'hr', 'boss')
    )
  );

-- Anyone can read reactions
CREATE POLICY "Anyone can read reactions" ON public.post_reactions
  FOR SELECT
  USING (true);

-- Authenticated users can add reactions
CREATE POLICY "Users can add reactions" ON public.post_reactions
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own reactions
CREATE POLICY "Users can delete own reactions" ON public.post_reactions
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Anyone can read comments (non-deleted)
CREATE POLICY "Anyone can read comments" ON public.post_comments
  FOR SELECT
  USING (is_deleted = false);

-- Authenticated users can add comments
CREATE POLICY "Users can add comments" ON public.post_comments
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update their own comments
CREATE POLICY "Users can update own comments" ON public.post_comments
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own comments (soft delete)
CREATE POLICY "Users can delete own comments" ON public.post_comments
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Admins can hard delete comments
CREATE POLICY "Admins can delete comments" ON public.post_comments
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'hr', 'boss')
    )
  );

