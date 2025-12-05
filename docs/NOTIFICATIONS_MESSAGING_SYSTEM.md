# Notifications & Messaging System

## Overview

Unified Notifications & Messaging system for RBM Pulse, aligned to role-based access, wellbeing sensitivity, and growth culture philosophy.

## Features

### 1. Notification Rules Engine

**Centralized Notification Service** with:
- **NotificationType enum**: 10 notification types (Achievement, Action, Follow-up, Discussion, Recognition, AI Coach, Zen Break, Meeting, Culture Post, Challenge)
- **NotificationPriority**: High, Normal, Low
- **Rate Limiting**: Max 10 notifications per user per hour
- **Context Awareness**: 
  - Hide during Focus Zone sessions
  - Quiet Hours: 9PM–8AM (configurable)
  - Prevent stack-flooding from streaks
- **Preference-based filtering**: Category toggles, channel selection

### 2. Messaging UI (Internal Conversation Layer)

**Productivity-focused messaging** (not a full chat app):
- **Context-based threads**: Meeting Room actions, Idea Lab feedback, Thought Circles replies
- **Features**:
  - @mention tagging
  - Message reactions (👍 💡 🙌 ❤️)
  - Image/screenshot attachments
  - Message summarization placeholder
  - Role-based visibility

### 3. Permission Matrix

| Role | Can Message | Can View All | Moderate | Manage Rules |
|------|-------------|--------------|----------|--------------|
| Employee | Own threads & team collab | ❌ | ❌ | ❌ |
| Team Lead | Team threads | Team scope | Limited | ❌ |
| HR | All employees | ✔ | ✔ | ✔ Team scope |
| Admin | All employees | ✔ | ✔ | ✔ |
| Super Admin | All systems | ✔ | ✔ | ✔ |

### 4. Notification Preferences Screen

**User-customizable settings**:
- **Category toggles**:
  - Achievements
  - Focus/Zen nudges
  - Social interactions
  - Action reminders
  - AI coach suggestions
- **Delivery channels**:
  - In-App
  - Email
- **Quiet Hours**: Configurable start/end time
- **Do Not Disturb**: Pause all notifications (except critical)

## Components

### Notification Components

1. **NotificationBadge** (`notification_badge.dart`)
   - Badge count display
   - Shows on notification icon

2. **NotificationPanel** (`notification_panel.dart`)
   - Full notification list
   - Filter tabs (All, Unread)
   - Mark all as read
   - Click to navigate to action

3. **NotificationItem** (`notification_item.dart`)
   - Individual notification card
   - Type icon and color
   - Priority indicator
   - Time formatting

4. **NotificationPreferencesScreen** (`notification_preferences_screen.dart`)
   - Full preferences UI
   - Category switches
   - Channel selection
   - Quiet hours picker
   - Do Not Disturb toggle

### Messaging Components

1. **MessageThreadView** (`message_thread_view.dart`)
   - Full thread conversation view
   - Message list with scroll
   - Message input at bottom

2. **MessageBubble** (`message_bubble.dart`)
   - Individual message display
   - Own vs. other user styling
   - Mentions display
   - Attachments preview
   - Reactions display

3. **MessageInput** (`message_input.dart`)
   - Text input with @mention support
   - Send button
   - Mention picker trigger

## Services

### NotificationService

**Methods:**
- `shouldSendNotification()` - Check rules before sending
- `getPreferences()` - Get user preferences
- `savePreferences()` - Save user preferences
- `getNotifications()` - Fetch notifications
- `markAsRead()` - Mark notification as read
- `markAllAsRead()` - Mark all as read
- `getUnreadCount()` - Get unread count
- `createNotification()` - Create new notification

**Rate Limiting:**
- Max 10 notifications per user per hour
- Automatic cleanup of old rate limit entries

**Context Checks:**
- Quiet hours validation
- Do Not Disturb check
- Category preference check
- Focus Zone session check (placeholder)

### MessagingService

**Methods:**
- `canSendMessage()` - Check permission to send
- `canViewThread()` - Check permission to view
- `getThread()` - Fetch thread details
- `getMessages()` - Fetch messages in thread
- `sendMessage()` - Send new message
- `addReaction()` - Add reaction to message
- `removeReaction()` - Remove reaction
- `getThreads()` - Get user's threads
- `createThread()` - Create new thread

## Database Schema

**File:** `db/supabase_notifications_messaging_schema.sql`

### Tables:

1. **notification_preferences**
   - User notification settings
   - Category toggles
   - Channel preferences
   - Quiet hours
   - Do Not Disturb

2. **notifications**
   - All user notifications
   - Type, priority, metadata
   - Read status
   - Action URLs

3. **message_threads**
   - Context-based conversation threads
   - Participant management
   - Context type and ID

4. **messages**
   - Individual messages
   - Mentions, attachments, reactions
   - Edit tracking

5. **message_moderation**
   - Flagged messages
   - Moderation workflow

6. **notification_rate_limits**
   - Rate limiting tracking
   - Automatic cleanup

### RLS Policies:
- Users can only access their own notifications
- Thread participants can view/send messages
- HR/Admin can view all threads
- Role-based moderation access

## Integration

### AppHeader Integration

- Notification icon with badge count
- Click to open NotificationPanel
- Auto-refresh unread count
- Pass `userId` to AppHeader to enable notifications

### Usage Example:

```dart
AppHeader(
  title: 'Dashboard',
  userId: userId, // Enables notification icon
  showMenu: true,
)
```

## Notification Types

| Type | Trigger Source | Example Text |
|------|---------------|--------------|
| AchievementUnlocked | Growth Score | "You unlocked Innovator Badge! ✨" |
| ActionAssigned | Meeting Room | "New Action Item from meeting: Fix API bug" |
| FollowUpDue | Meeting Room | "Follow-up due today ⏳" |
| DiscussionReply | Thought Circles | "Ravi replied to your idea 💬" |
| RecognitionReceived | Inside RBM | "5 people marked this as Inspiring 🔥" |
| AI_Coach_Nudge | Future Me | "10 min logic challenge for +3% growth!" |
| ZenBreakPrompt | Mind Balance | "Screen time high — relax your eyes 👀✨" |
| MeetingReminder | Meeting Room | "Meeting starts in 15 minutes" |
| CulturePostFeatured | Inside RBM | "Your post was featured! 🌟" |
| WeeklyChallengeComplete | Future Me | "Weekly challenge completed! 🎉" |

## Future Enhancements

### Planned Features:
- Real-time push notifications
- WebSocket integration for live messaging
- Email notification delivery
- Notification grouping/summarization
- Message search functionality
- Voice messages
- File attachments
- Message threading improvements
- Notification scheduling
- Smart notification prioritization

### AI Integration:
- Message summarization
- Smart notification timing
- Context-aware notification grouping
- Sentiment-based notification filtering

## Security & Privacy

- All data access controlled via RLS policies
- Rate limiting prevents spam
- Role-based permission enforcement
- Message moderation for inappropriate content
- Privacy-respecting notification preferences

## Usage

1. **Enable Notifications:**
   - Pass `userId` to `AppHeader`
   - Notification icon appears automatically
   - Click to view notifications

2. **Configure Preferences:**
   - Navigate to Notification Preferences screen
   - Toggle categories
   - Set quiet hours
   - Choose delivery channels

3. **Send Messages:**
   - Use `MessageThreadView` in relevant modules
   - Type message with @mentions
   - Add reactions
   - Attach images

4. **Moderate Messages:**
   - HR/Admin can flag inappropriate content
   - Review in moderation queue
   - Take action (resolve/dismiss)

## Notes

- All screens use mocked data currently
- Ready for Supabase backend integration
- Role-based routing implemented
- UI scaffolding complete
- Database schema provided
- API contract defined
- Rate limiting implemented
- Context awareness ready

