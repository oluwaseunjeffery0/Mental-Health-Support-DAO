Crisis Support Alert System

Overview
Introduces a comprehensive crisis support alert system for the Mental Health Support DAO, enabling users to create and respond to mental health crisis situations. This independent feature operates without cross-contract dependencies, providing immediate crisis response capabilities with qualified responder verification, severity tracking, and automated reward distribution.

Technical Implementation
Key functions and data structures added:

**Core Data Structures:**
- `crisis-alerts` map: Stores alert details with severity levels (1-5), contact methods, location hints, and response tracking
- `crisis-responders` map: Manages qualified responders with specialization, certification levels, and availability status
- `alert-responses` map: Records responder interactions with follow-up requirements

**Primary Functions:**
- `create-crisis-alert`: Creates alerts with 1-5 severity levels and contact information
- `register-crisis-responder` & `verify-crisis-responder`: Registration and owner verification system
- `respond-to-crisis-alert`: Qualified responder response mechanism with automatic reward calculation
- `resolve-crisis-alert`: Resolution tracking with token rewards (severity × 50 tokens)
- `escalate-crisis-alert`: Owner-controlled escalation for unresponded alerts
- `update-responder-availability`: Real-time availability management

**Features:**
- Severity-based reward system (50-250 tokens per resolution)
- Response time tracking and urgency scoring
- Qualification verification and availability management
- Automatic escalation after configurable time limits
- Comprehensive responder statistics and performance tracking

Testing & Validation
✅ Contract passes clarinet check (36 warnings for unchecked data, standard for user inputs)
✅ All npm tests successful
✅ CI/CD pipeline configured with GitHub Actions
✅ Clarity v3 compliant with proper error handling and data types
