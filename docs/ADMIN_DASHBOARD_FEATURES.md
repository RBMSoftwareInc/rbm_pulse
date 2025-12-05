# Admin & Leadership Control Dashboards

## Overview

Comprehensive admin and leadership control system for RBM Pulse, providing role-based access to monitor culture, growth, innovation, well-being, and performance metrics.

## User Roles & Access

### Roles
- **Employee** (default) - Basic access
- **Team Lead** - Team-level analytics
- **HR Manager** - Employee wellness and culture management
- **Admin** - Organization-wide control
- **Super Admin** - System configuration and control

### Permission Matrix

| Feature                  | Employee | Lead  | HR      | Admin    | Super Admin |
| ------------------------ | :------: | :---: | :-----: | :------: | :---------: |
| View Inside RBM          |    ✔     |   ✔   |    ✔    |    ✔     |      ✔      |
| Post to Inside RBM       | Limited  |   ✔   |    ✔    |    ✔     |      ✔      |
| Approve Culture Posts    |    ❌    | Limited |   ✔    |    ✔     |      ✔      |
| View Growth Analytics    | Own only | Team  | All     | All+Dept |  All+System |
| Manage AI Settings       |    ❌    |   ❌  |    ❌    | Limited  |      ✔      |
| Manage Roles & Access    |    ❌    |   ❌  | Team scope |   ✔     |      ✔      |
| Configure Company Values |    ❌    |   ❌  |    ✔    |    ✔     |      ✔      |
| View Meeting Insights    | Own only | Team  |   All   | Dept/Company |   Full    |

## Admin Modules

### 1. Admin & HR Command Dashboard
**Main entry point for all admin features**

**Features:**
- Active alerts display (burnout, stress, meeting overload, low engagement)
- AI-generated narrative panel with weekly insights
- Key metrics cards (Pulse Score, Culture Health, Innovation Index, Wellbeing Score)
- Top contributors showcase
- Quick navigation to all admin modules

**Location:** `lib/features/admin/admin_dashboard_screen.dart`

### 2. Pulse Score Heatmap
**Team → Organization analytics**

**Features:**
- Visual heatmap of team pulse scores
- Burnout and engagement indicators
- Team-level drill-down capability
- Color-coded risk levels

**Location:** `lib/features/admin/screens/pulse_heatmap_screen.dart`

### 3. Culture Health Trends
**Engagement & sentiment tracking**

**Features:**
- Health score trend chart (line graph)
- Total posts, positive reactions, engagement rate metrics
- Historical trend analysis
- Real-time culture health monitoring

**Location:** `lib/features/admin/screens/culture_health_screen.dart`

### 4. Innovation Index
**Idea Lab analytics**

**Features:**
- Department-level innovation metrics
- Total ideas vs. implemented ideas
- Impact score calculation
- Top contributors by department
- Implementation rate tracking

**Location:** `lib/features/admin/screens/innovation_index_screen.dart`

### 5. Wellbeing Console
**HR wellness monitoring**

**Features:**
- Employee wellbeing metrics dashboard
- Risk level filtering (Low, Moderate, High, Critical)
- Burnout risk and engagement scores
- Mind Balance streak tracking
- Focus consistency metrics
- Intervention suggestions (coaching, break reminders, recognition)

**Location:** `lib/features/admin/screens/wellbeing_console_screen.dart`

### 6. Meeting Governance
**Productivity & quality tracking**

**Features:**
- Team meeting quality metrics
- Action item completion rates
- Meeting overload alerts
- Productivity score calculation
- Low action completion warnings

**Location:** `lib/features/admin/screens/meeting_governance_screen.dart`

### 7. Post Moderation & Spotlight
**Content approval & culture promotion**

**Features:**
- Post moderation queue (Pending, Approved, Flagged, Rejected)
- Approve/Reject actions
- Feature post on hero banner
- Flagged content review
- Reaction count tracking

**Location:** `lib/features/admin/screens/post_moderation_screen.dart`

### 8. Growth Analytics Console
**Future Me insights for leaders**

**Features:**
- Employee growth analytics
- Skill gap identification
- High-potential employee detection
- Career path recommendations
- Mentor matchmaking suggestions
- Export growth readiness reports for appraisals

**Location:** `lib/features/admin/screens/growth_analytics_console_screen.dart`

### 9. AI Management Console
**Content & scoring rules**

**Features:**
- Content generation rules configuration
- Topic bank management (Thought Circles)
- Puzzle difficulty algorithm settings
- Innovation scoring criteria
- Zen activity triggers (stress-based)
- Culture filters (AI guardrails)
- AI training data labels (Growth Positive, Neutral, Avoid)

**Location:** `lib/features/admin/screens/ai_management_screen.dart`

### 10. Configuration & Control
**Super Admin system settings**

**Features:**
- Feature toggles (AR Experiences, Meeting Recording, Anonymous Mode)
- Organization values library
- Seasonal themes & banners
- Database backup & export settings
- Login & SSO control
- App update notifications

**Location:** `lib/features/admin/screens/config_control_screen.dart`

## Data Models

### Core Models (`lib/features/admin/models/admin_models.dart`)

- `UserRole` - Role enumeration with permissions
- `PulseHeatmapData` - Team pulse score data
- `CultureHealthTrend` - Culture metrics over time
- `InnovationIndex` - Innovation metrics by department
- `SkillDevelopmentData` - Skill learning progress
- `MeetingQualityMetrics` - Meeting productivity data
- `WellbeingMetrics` - Employee wellness data
- `Alert` - Admin alerts and notifications
- `TopContributor` - Top performers by category
- `AISetting` - AI configuration settings
- `PostModerationItem` - Post moderation queue items
- `GrowthAnalytics` - Employee growth predictions

## Service Layer

### AdminService (`lib/features/admin/services/admin_service.dart`)

**Methods:**
- `getPulseHeatmap()` - Fetch team pulse scores
- `getCultureHealthTrends()` - Get culture health history
- `getInnovationIndex()` - Department innovation metrics
- `getSkillDevelopmentData()` - Skill learning analytics
- `getMeetingQualityMetrics()` - Meeting productivity data
- `getWellbeingMetrics()` - Employee wellness data
- `getAlerts()` - Active admin alerts
- `getTopContributors()` - Top performers
- `getAINarrative()` - AI-generated insights
- `getGrowthAnalytics()` - Growth predictions
- `getModerationQueue()` - Post moderation queue
- `approvePost()` - Approve culture post
- `rejectPost()` - Reject culture post
- `featurePost()` - Feature post on hero

## Database Schema

**File:** `db/supabase_admin_schema.sql`

### Tables Created:
1. `organizations` - Multi-tenant organization support
2. `teams` - Organizational teams and departments
3. `ai_settings` - AI configuration and rules
4. `meeting_metrics` - Team-level meeting productivity
5. `culture_metrics` - Organization culture health
6. `employee_focus_data` - Focus zone activity
7. `burnout_risk_data` - Burnout risk assessments
8. `badge_awards` - Gamification badges
9. `audit_logs` - System audit trail
10. `admin_alerts` - Admin alerts and notifications
11. `post_moderation_queue` - Post moderation workflow

### RLS Policies:
- Role-based access control for all tables
- Team leads see their team data
- HR/Admin see all employee data
- Super Admin has full system access

## Navigation

### Dashboard Integration
- Admin Dashboard tile appears on main dashboard for non-employee roles
- Accessible via hamburger menu → "Admin Console"
- Role-based visibility and permissions enforced

### App Drawer
- "Admin Console" menu item for HR/Admin roles
- Direct navigation to admin dashboard

## UI Components

### Reusable Widgets (`lib/features/admin/widgets/`)

1. **AlertCard** - Displays admin alerts with severity indicators
2. **MetricCard** - Key metric display cards
3. **AINarrativePanel** - AI-generated insights panel

## Future Enhancements

### Planned Features:
- Real-time data synchronization
- Advanced filtering and drill-downs
- Export functionality (PDF, CSV)
- Email notifications for critical alerts
- Custom dashboard configuration
- Advanced analytics and ML predictions
- Integration with external HR systems

### AI Integration:
- Real AI content generation
- Predictive analytics for burnout
- Automated intervention suggestions
- Sentiment analysis from Thought Circles
- Smart mentor matching algorithms

## Security & Privacy

- All data access controlled via RLS policies
- Audit logging for accountability
- Role-based permission enforcement
- Ethical wellbeing monitoring (supportive, not punitive)
- Data privacy compliance (GDPR-ready)

## Usage

1. **Access Admin Dashboard:**
   - Login as HR/Admin role
   - Navigate to "Admin Console" from dashboard or drawer

2. **Monitor Culture:**
   - View Culture Health Trends
   - Moderate posts in Post Moderation
   - Review innovation metrics

3. **Track Wellbeing:**
   - Check Wellbeing Console for risk alerts
   - Review burnout risk data
   - Suggest interventions

4. **Manage AI:**
   - Configure AI settings in AI Management Console
   - Train AI with culture labels
   - Adjust scoring algorithms

5. **System Control:**
   - Super Admin: Configure system settings
   - Manage feature toggles
   - Control SSO and authentication

## Notes

- All screens use mocked data currently
- Ready for Supabase backend integration
- Role-based routing implemented
- UI scaffolding complete
- Database schema provided
- API contract defined

