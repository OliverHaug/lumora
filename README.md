Lumora — A Social Healing & Coaching Platform
Lumora is a digital platform that connects people on a healing and growth journey with the coaches who fit them best.

Through intelligent matching, personal profiles, and real-time communication, Lumora creates long-term, trust-based coaching relationships instead of random or transactional encounters.

🌿 Vision
Mental health challenges are increasing worldwide, especially since the COVID-19 pandemic.
At the same time, access to psychologists is limited, waiting lists are long, and people are searching for alternative but trustworthy support.

Lumora exists to close this gap.

We connect people who are ready to invest in their healing journey with coaches who truly fit them — emotionally, professionally, and energetically.

🚩 The Problem
Psychological services are overloaded
Many people cannot access therapy in time
Coaching is growing rapidly — but:
Quality is inconsistent
Trust is hard to build
Users lack orientation
People want support, but don’t know who to trust.

💡 The Solution
Lumora is a Flutter-based platform (mobile + web) that:

Matches clients with compatible coaches using a guided questionnaire
Stores personality traits, coaching styles and specialties in a structured database
Shows match percentages visually
Allows filtering by price, language, and specialization
Gives coaches professional profile pages with curated content
Beyond matching, Lumora becomes a social healing ecosystem.

✨ Core Platform Features
🧩 Smart Matching
Clients answer a short, guided questionnaire
Coaches define their focus, approach, and specialties
The system calculates compatibility scores
Users see who fits them best
🧑 Coach Profiles
Personal introduction
Focus areas and philosophy
Languages and availability
Media (text, image, video)
💬 Inbox & Real-Time Chat
Direct messaging between clients and coaches
WhatsApp-style UI
Realtime unread badges
Read receipts
Message & conversation caching for fast UX
🌍 Community Safe Space
A social network designed for:

Reflection
Healing
Conscious growth
Not vanity or endless scrolling.
Users can:

Share posts
Follow others
Discover new perspectives
Connect naturally
🎓 Workshops & Retreats (Expansion)
Coaches can offer paid workshops
Retreats can be listed with filters (price, location, theme, time)
Platform earns a small mediation fee
🧠 Technology Stack
Frontend
Flutter (Mobile & Web)
Riverpod
Bloc
GoRouter
Hive (offline caching)
Backend
Supabase
PostgreSQL
Realtime channels
Postgres RPC functions
Row Level Security
The architecture is designed for:

Realtime chat
Scalable matching
Secure personal data
Offline-first UX
🗄 Backend Architecture
Lumora uses:

users
conversations
messages
inbox_events
Coach & profile tables
With server-side RPC functions like:

get_or_create_direct_conversation
messages_page
inbox_conversations
inbox_unread_total
mark_conversation_read
Unread counts, sorting, and message pagination are calculated on the server for accuracy and performance.

💰 Business Model
Commission per successful match (percentage of coaching fee)
Commission on workshops and retreats
Optional premium visibility for coaches (future)
👥 Target Groups
Clients
People with emotional, psychological or personal growth needs
Those who cannot find or afford traditional therapy
Those seeking conscious, holistic support
Coaches
Professional, qualified coaches
Especially valuable for newcomers who need visibility
Coaches looking for aligned, long-term clients
🔐 Ethics & Responsibility
Lumora makes a clear distinction:

Coaches are guides, not therapists
Clients remain responsible for their own progress
Legal disclaimers and boundaries are built into the platform
The goal is safety, clarity and trust.

🚀 Getting Started
git clone https://github.com/OliverHaug/lumora.git
cd lumora
flutter pub get
