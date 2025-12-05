-- Generic questions for team bonding, introspection, project inquiry, etc.
-- These questions are not role-specific and apply to all employees

-- First, ensure we have the necessary scales and factors
INSERT INTO public.survey_scales (code, name, description, is_active) VALUES
  ('TEAM_BONDING', 'Team Bonding', 'Measures team cohesion and collaboration', true),
  ('SELF_INTROSPECTION', 'Self Introspection', 'Measures self-awareness and personal reflection', true),
  ('TEAM_INTROSPECTION', 'Team Introspection', 'Measures team self-awareness and collective reflection', true),
  ('PROJECT_INQUIRY', 'Project Inquiry', 'Measures project understanding and engagement', true),
  ('WORK_LIFE_BALANCE', 'Work-Life Balance', 'Measures balance between work and personal life', true),
  ('COMMUNICATION', 'Communication', 'Measures communication effectiveness', true),
  ('COLLABORATION', 'Collaboration', 'Measures collaborative behaviors', true)
ON CONFLICT (code) DO NOTHING;

-- Ensure we have generic factors
-- Handle conflicts on both code and name (both are unique)
-- Use separate inserts with proper conflict handling
INSERT INTO public.survey_factors (code, name, description, category, is_active) 
SELECT * FROM (VALUES
  ('TEAM_COHESION', 'Team Cohesion', 'Strength of team bonds and relationships', 'social', true),
  ('SELF_AWARENESS', 'Self Awareness', 'Understanding of own strengths and weaknesses', 'personal', true),
  ('TEAM_AWARENESS', 'Team Awareness', 'Understanding of team dynamics and needs', 'social', true),
  ('PROJECT_UNDERSTANDING', 'Project Understanding', 'Clarity on project goals and requirements', 'work', true),
  ('BALANCE', 'Work-Life Balance', 'Balance between professional and personal life', 'wellbeing', true),
  ('COMMUNICATION_EFFECTIVENESS', 'Communication Effectiveness', 'Quality of communication within team', 'social', true),
  ('COLLABORATIVE_SPIRIT', 'Collaborative Spirit', 'Willingness and ability to collaborate', 'social', true)
) AS v(code, name, description, category, is_active)
WHERE NOT EXISTS (
  SELECT 1 FROM public.survey_factors 
  WHERE survey_factors.code = v.code OR survey_factors.name = v.name
);

-- Generic Team Bonding Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'TEAM_BONDING'),
  (SELECT id FROM survey_factors WHERE code = 'TEAM_COHESION'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('I feel a strong sense of belonging with my team', 1.0, false, 1, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('My team members support each other during challenging times', 1.0, false, 2, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('I enjoy working with my team members', 1.0, false, 3, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('Our team celebrates successes together', 1.0, false, 4, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('I feel comfortable sharing ideas and concerns with my team', 1.0, false, 5, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('Team conflicts are resolved constructively', 1.0, false, 6, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('I trust my team members to deliver on their commitments', 1.0, false, 7, '{"category": "team_bonding", "generic": true}'::jsonb),
  ('Our team has a shared vision and goals', 1.0, false, 8, '{"category": "team_bonding", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Self Introspection Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'SELF_INTROSPECTION'),
  (SELECT id FROM survey_factors WHERE code = 'SELF_AWARENESS'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('I regularly reflect on my performance and areas for improvement', 1.0, false, 1, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I am aware of my strengths and leverage them effectively', 1.0, false, 2, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I acknowledge my weaknesses and work on improving them', 1.0, false, 3, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I seek feedback to understand how others perceive my work', 1.0, false, 4, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I take time to understand my emotions and reactions at work', 1.0, false, 5, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I set personal development goals and track my progress', 1.0, false, 6, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I learn from my mistakes and failures', 1.0, false, 7, '{"category": "self_introspection", "generic": true}'::jsonb),
  ('I understand how my actions impact my team and organization', 1.0, false, 8, '{"category": "self_introspection", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Team Introspection Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'TEAM_INTROSPECTION'),
  (SELECT id FROM survey_factors WHERE code = 'TEAM_AWARENESS'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('Our team regularly reflects on what went well and what could improve', 1.0, false, 1, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('We discuss team dynamics and how we work together', 1.0, false, 2, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('Our team identifies and addresses process inefficiencies', 1.0, false, 3, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('We learn from project failures and setbacks as a team', 1.0, false, 4, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('Our team adapts and improves based on feedback', 1.0, false, 5, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('We have open discussions about team challenges', 1.0, false, 6, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('Our team celebrates learning and growth opportunities', 1.0, false, 7, '{"category": "team_introspection", "generic": true}'::jsonb),
  ('We regularly assess if we are meeting our team goals', 1.0, false, 8, '{"category": "team_introspection", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Project Inquiry Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'PROJECT_INQUIRY'),
  (SELECT id FROM survey_factors WHERE code = 'PROJECT_UNDERSTANDING'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('I clearly understand the project goals and objectives', 1.0, false, 1, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I know my role and responsibilities in the project', 1.0, false, 2, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I understand how my work contributes to project success', 1.0, false, 3, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('Project requirements and expectations are clear to me', 1.0, false, 4, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I have access to the information I need to complete my work', 1.0, false, 5, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I understand the project timeline and milestones', 1.0, false, 6, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I know who to contact for project-related questions', 1.0, false, 7, '{"category": "project_inquiry", "generic": true}'::jsonb),
  ('I feel engaged and motivated by the project work', 1.0, false, 8, '{"category": "project_inquiry", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Work-Life Balance Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'WORK_LIFE_BALANCE'),
  (SELECT id FROM survey_factors WHERE code = 'BALANCE'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('I am able to maintain a healthy balance between work and personal life', 1.0, false, 1, '{"category": "work_life_balance", "generic": true}'::jsonb),
  ('I take regular breaks during work hours', 1.0, false, 2, '{"category": "work_life_balance", "generic": true}'::jsonb),
  ('I can disconnect from work during personal time', 1.0, false, 3, '{"category": "work_life_balance", "generic": true}'::jsonb),
  ('My workload allows me to have time for personal activities', 1.0, false, 4, '{"category": "work_life_balance", "generic": true}'::jsonb),
  ('I feel rested and energized for work most days', 1.0, false, 5, '{"category": "work_life_balance", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Communication Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'COMMUNICATION'),
  (SELECT id FROM survey_factors WHERE code = 'COMMUNICATION_EFFECTIVENESS'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('Communication within my team is clear and effective', 1.0, false, 1, '{"category": "communication", "generic": true}'::jsonb),
  ('I receive timely updates about important information', 1.0, false, 2, '{"category": "communication", "generic": true}'::jsonb),
  ('I feel comfortable expressing my opinions and concerns', 1.0, false, 3, '{"category": "communication", "generic": true}'::jsonb),
  ('Feedback is provided constructively and regularly', 1.0, false, 4, '{"category": "communication", "generic": true}'::jsonb),
  ('Team meetings are productive and well-organized', 1.0, false, 5, '{"category": "communication", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

-- Generic Collaboration Questions
INSERT INTO public.survey_questions (prompt, scale_id, factor_id, weight, reverse_scored, order_index, metadata) 
SELECT 
  prompt,
  (SELECT id FROM survey_scales WHERE code = 'COLLABORATION'),
  (SELECT id FROM survey_factors WHERE code = 'COLLABORATIVE_SPIRIT'),
  weight,
  reverse_scored,
  order_index,
  metadata
FROM (VALUES
  ('I collaborate effectively with team members on projects', 1.0, false, 1, '{"category": "collaboration", "generic": true}'::jsonb),
  ('Team members share knowledge and help each other', 1.0, false, 2, '{"category": "collaboration", "generic": true}'::jsonb),
  ('We work together to solve problems and overcome challenges', 1.0, false, 3, '{"category": "collaboration", "generic": true}'::jsonb),
  ('Cross-functional collaboration happens smoothly', 1.0, false, 4, '{"category": "collaboration", "generic": true}'::jsonb),
  ('I feel my contributions are valued in team collaborations', 1.0, false, 5, '{"category": "collaboration", "generic": true}'::jsonb)
) AS t(prompt, weight, reverse_scored, order_index, metadata);

