-- Add designation column to profiles table
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS designation VARCHAR(100);

-- Create designations reference table
CREATE TABLE IF NOT EXISTS public.designations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  role VARCHAR(50) NOT NULL, -- employee, manager, leader, etc.
  responsibilities JSONB, -- Array of responsibility strings
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common designations
INSERT INTO public.designations (code, name, description, role, responsibilities) VALUES
  ('delivery_head', 'Delivery Head', 'Oversees project delivery and team coordination', 'manager', 
   '["Project delivery", "Team coordination", "Client communication", "Resource allocation"]'::jsonb),
  ('project_lead', 'Project Lead', 'Leads project execution and team management', 'manager',
   '["Project planning", "Team leadership", "Stakeholder management", "Risk management"]'::jsonb),
  ('tech_lead', 'Tech Lead', 'Technical leadership and architecture decisions', 'leader',
   '["Technical architecture", "Code reviews", "Technical mentoring", "Technology decisions"]'::jsonb),
  ('team_lead', 'Team Lead', 'Manages team operations and development', 'manager',
   '["Team management", "Performance reviews", "Resource planning", "Process improvement"]'::jsonb),
  ('senior_developer', 'Senior Developer', 'Senior technical contributor', 'employee',
   '["Feature development", "Code quality", "Mentoring juniors", "Technical problem solving"]'::jsonb),
  ('developer', 'Developer', 'Software development and implementation', 'employee',
   '["Feature development", "Bug fixes", "Code implementation", "Testing"]'::jsonb),
  ('architect', 'Solution Architect', 'Designs system architecture and solutions', 'leader',
   '["System design", "Architecture decisions", "Technical strategy", "Solution design"]'::jsonb),
  ('qa_lead', 'QA Lead', 'Quality assurance leadership', 'manager',
   '["Test strategy", "Quality standards", "Team management", "Process improvement"]'::jsonb),
  ('qa_engineer', 'QA Engineer', 'Quality assurance and testing', 'employee',
   '["Test execution", "Bug reporting", "Test automation", "Quality validation"]'::jsonb),
  ('devops_engineer', 'DevOps Engineer', 'Infrastructure and deployment', 'employee',
   '["CI/CD", "Infrastructure management", "Monitoring", "Automation"]'::jsonb),
  ('product_manager', 'Product Manager', 'Product strategy and roadmap', 'manager',
   '["Product strategy", "Roadmap planning", "Stakeholder alignment", "Feature prioritization"]'::jsonb),
  ('business_analyst', 'Business Analyst', 'Requirements and analysis', 'employee',
   '["Requirements gathering", "Analysis", "Documentation", "Stakeholder communication"]'::jsonb),
  ('scrum_master', 'Scrum Master', 'Agile process facilitation', 'employee',
   '["Sprint planning", "Retrospectives", "Process facilitation", "Team coaching"]'::jsonb),
  ('ui_ux_designer', 'UI/UX Designer', 'User interface and experience design', 'employee',
   '["Design creation", "User research", "Prototyping", "Design systems"]'::jsonb),
  ('data_analyst', 'Data Analyst', 'Data analysis and insights', 'employee',
   '["Data analysis", "Reporting", "Insights generation", "Data visualization"]'::jsonb),
  ('hr_manager', 'HR Manager', 'Human resources management', 'hr',
   '["Recruitment", "Employee relations", "Policy management", "Performance management"]'::jsonb),
  ('finance_manager', 'Finance Manager', 'Financial management and accounting', 'manager',
   '["Budgeting", "Financial reporting", "Cost management", "Financial analysis"]'::jsonb),
  ('operations_manager', 'Operations Manager', 'Operations and process management', 'manager',
   '["Process optimization", "Resource management", "Operations planning", "Efficiency improvement"]'::jsonb),
  ('sales_manager', 'Sales Manager', 'Sales and business development', 'manager',
   '["Sales strategy", "Client relationships", "Revenue generation", "Market expansion"]'::jsonb),
  ('director', 'Director', 'Strategic leadership and direction', 'leader',
   '["Strategic planning", "Leadership", "Decision making", "Organizational growth"]'::jsonb)
ON CONFLICT (code) DO NOTHING;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_designations_role ON public.designations(role);
CREATE INDEX IF NOT EXISTS idx_designations_active ON public.designations(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_profiles_designation ON public.profiles(designation);

-- Add comments
COMMENT ON TABLE public.designations IS 'Reference table for employee designations and their responsibilities';
COMMENT ON COLUMN public.profiles.designation IS 'Employee designation code (references designations.code)';

