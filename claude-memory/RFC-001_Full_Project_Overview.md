# RFC-001: STA Scholarship Application Management System

**Version:** 2.0
**Status:** Pending Review
**Author:** Ethan Fitzsimmons
**Date:** December 2025
**Classification:** Internal Technical Document

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Background](#2-project-background)
3. [System Goals and Objectives](#3-system-goals-and-objectives)
4. [Technical Architecture](#4-technical-architecture)
5. [Database Design](#5-database-design)
6. [Core System Components](#6-core-system-components)
7. [User Roles and Authentication](#7-user-roles-and-authentication)
8. [Application Lifecycle Management](#8-application-lifecycle-management)
9. [Financial Tracking System](#9-financial-tracking-system)
10. [Email and Notification System](#10-email-and-notification-system)
11. [Implementation Phases](#11-implementation-phases)
12. [Security Considerations](#12-security-considerations)
13. [Deployment Strategy](#13-deployment-strategy)
14. [Open Questions](#14-open-questions)
15. [Appendix: Database Schema Reference](#15-appendix-database-schema-reference)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides a comprehensive technical specification for the Sitka Tribe of Alaska (STA) Scholarship Application Management System. The system will replace the current paper-based scholarship application process with a modern digital platform, enabling efficient application submission, verification, and award management.

### 1.2 Scope

The STA Scholarship Application Management System encompasses:

- **Digital application submission** for tribal members seeking educational funding
- **Administrative tools** for staff to review, verify, and process applications
- **Board member portal** for review and voting on scholarship awards
- **Financial tracking** for lifetime award management and threshold monitoring
- **Automated communications** for application status updates and document requests
- **Historical data management** for transitioning from paper records

### 1.3 Key Outcomes

Upon completion, this system will:

1. Eliminate manual paper-based processing, reducing administrative overhead
2. Provide real-time visibility into application status for staff and applicants
3. Enable accurate lifetime award tracking across undergraduate and graduate programs
4. Support board member review processes with structured voting workflows
5. Automate routine communications with applicants and educational institutions
6. Create a foundation for data-driven decision making and reporting

### 1.4 Technical Summary

The system is built on:

- **Framework:** Ruby on Rails 8.0.1
- **Database:** PostgreSQL
- **Development Environment:** Docker containerization
- **Deployment Target:** Ubuntu server (AWS container-based deployment planned)
- **Architecture:** Server-side rendered application with Stimulus/Turbo for enhanced interactivity

---

## 2. Project Background

### 2.1 Organizational Context

The Sitka Tribe of Alaska operates a scholarship program providing financial assistance to tribal members pursuing higher education. The program supports both undergraduate and graduate studies, with separate funding pools and lifetime award limits for each educational level.

### 2.2 Current State

The existing scholarship application process relies on:

- **Paper applications** distributed as PDF forms
- **Manual processing** by staff members
- **Limited tracking** of historical awards and student progress
- **No centralized database** linking students to their application history
- **Email-based communications** without structured tracking

This approach presents significant challenges:

- Time-consuming manual data entry and verification
- Difficulty tracking lifetime awards across multiple applications
- No visibility into application status for students
- Risk of data loss or inconsistency across paper records
- Inability to analyze program effectiveness with data

### 2.3 Vision

Transform the scholarship program into a fully digital, data-driven operation where:

- Students submit applications through an intuitive web interface
- Staff process applications efficiently with structured verification workflows
- Board members review applications and vote through a dedicated portal
- Lifetime award tracking ensures compliance with funding limits
- Automated communications keep all parties informed
- Historical data is preserved and accessible for informed decision-making

---

## 3. System Goals and Objectives

### 3.1 Primary Goals

#### Goal 1: Digital Application Submission
Enable students to submit scholarship applications online, replacing the paper-based PDF form while maintaining all existing data collection requirements.

**Success Criteria:**
- 100% of required application fields captured digitally
- File upload capability for supporting documents
- Immediate confirmation of submission with tracking number

#### Goal 2: Efficient Application Processing
Provide staff with tools to review, verify, and process applications in a structured workflow.

**Success Criteria:**
- Single interface displaying all current applications
- Verification checklist with auto-save functionality
- Clear visibility into application status and pending items

#### Goal 3: Accurate Financial Tracking
Maintain precise records of all awards across a student's lifetime, ensuring compliance with program limits.

**Success Criteria:**
- Automatic calculation of lifetime award totals
- Warning system when approaching or exceeding limits
- Support for both undergraduate ($15,000) and graduate ($9,000) limits

#### Goal 4: Board Review Integration
Enable board members to review applications and submit votes through a dedicated portal.

**Success Criteria:**
- Read-only application access for board members
- Structured voting (approve/deny/abstain) with feedback
- Aggregated results visible to staff for final decisions

#### Goal 5: Automated Communications
Reduce manual communication burden through automated, trackable email workflows.

**Success Criteria:**
- Automatic FNA requests to educational institutions upon application submission
- Email templates for common communications
- Delivery tracking and notification management

### 3.2 Secondary Goals

- **Historical Data Integration:** Import and link paper-based historical records to digital student profiles
- **Reporting and Analytics:** Generate insights on program effectiveness and funding distribution
- **Audit Trail:** Maintain complete records of all actions for compliance and accountability
- **Mobile Accessibility:** Ensure responsive design for access across devices

---

## 4. Technical Architecture

### 4.1 Technology Stack

#### Framework: Ruby on Rails 8.0.1

Ruby on Rails was selected for its:

- **Rapid development** capabilities through convention over configuration
- **Mature ecosystem** with extensive libraries (gems) for common functionality
- **Strong database integration** through ActiveRecord ORM
- **Built-in security features** protecting against common vulnerabilities
- **Active community** providing ongoing support and updates

#### Database: PostgreSQL

PostgreSQL serves as the primary data store, chosen for:

- **ACID compliance** ensuring data integrity
- **Advanced data types** including JSON for flexible schema elements
- **Robust indexing** for performance optimization
- **Excellent Rails integration** through the pg gem
- **Production-ready reliability** with proven scalability

#### Frontend: Hotwire (Turbo + Stimulus)

The frontend utilizes Rails' default Hotwire approach:

- **Turbo Drive** for seamless page navigation without full reloads
- **Turbo Frames** for partial page updates
- **Stimulus** for JavaScript behaviors where needed
- **Server-side rendering** for initial page loads and SEO
- **Propshaft** asset pipeline for CSS and JavaScript delivery

### 4.2 Development Environment

Development utilizes Docker containerization to ensure consistency:

```
Docker Environment:
- Ruby 3.3.8
- Rails 8.0.1
- PostgreSQL (production database)
- SQLite3 (development/test convenience option)
```

Docker provides:

- **Environment consistency** across all development machines
- **Simplified setup** for new team members
- **Production parity** matching deployment environment
- **Isolation** from host system dependencies

### 4.3 Application Architecture

The application follows a standard Rails Model-View-Controller (MVC) architecture:

```
Application Structure:
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|   Controllers    |---->|     Models       |---->|    Database      |
|                  |     |                  |     |                  |
+--------+---------+     +------------------+     +------------------+
         |
         v
+------------------+
|                  |
|      Views       |
|                  |
+------------------+
```

**Controllers** handle HTTP requests and coordinate responses:
- `ScholarshipApplicationsController` - Student-facing application submission
- `Admin::ApplicationsController` - Staff application management
- `Admin::StudentsController` - Student profile management
- `Admin::VerificationsController` - Verification workflow
- `Admin::BoardController` - Board member portal

**Models** encapsulate business logic and data access:
- `Student` - Core identity and lifetime tracking
- `Application` - Individual scholarship applications
- `VerificationTemplate` - Application verification status
- `ApplicationFile` - Document attachments
- `User` - Authentication and authorization

**Views** render HTML responses:
- ERB templates with partials for reusable components
- Responsive CSS using custom stylesheets
- Minimal JavaScript through Stimulus controllers

### 4.4 System Diagram

```
+------------------------------------------------------------------+
|                        STA Scholarship System                      |
+------------------------------------------------------------------+
|                                                                    |
|  +------------------+    +------------------+    +---------------+ |
|  |                  |    |                  |    |               | |
|  |    Students      |    |      Staff       |    | Board Members | |
|  |   (Applicants)   |    |   (Admin/Staff)  |    |   (Reviewers) | |
|  |                  |    |                  |    |               | |
|  +--------+---------+    +--------+---------+    +-------+-------+ |
|           |                       |                      |         |
|           v                       v                      v         |
|  +------------------+    +------------------+    +---------------+ |
|  |   Application    |    |  Verification    |    |    Board      | |
|  |   Submission     |    |    Workflow      |    |    Portal     | |
|  |   Interface      |    |    Interface     |    |   Interface   | |
|  +--------+---------+    +--------+---------+    +-------+-------+ |
|           |                       |                      |         |
|           +-----------+-----------+----------------------+         |
|                       |                                            |
|                       v                                            |
|           +------------------------+                               |
|           |                        |                               |
|           |   Rails Application    |                               |
|           |     (Controllers,      |                               |
|           |   Models, Services)    |                               |
|           |                        |                               |
|           +----------+-------------+                               |
|                      |                                             |
|                      v                                             |
|           +------------------------+                               |
|           |                        |                               |
|           |      PostgreSQL        |                               |
|           |       Database         |                               |
|           |                        |                               |
|           +------------------------+                               |
|                                                                    |
|           +------------------------+                               |
|           |                        |                               |
|           |    Email Service       |                               |
|           |  (SendGrid/Postmark)   |                               |
|           |                        |                               |
|           +------------------------+                               |
|                                                                    |
+------------------------------------------------------------------+
```

---

## 5. Database Design

### 5.1 Design Philosophy

The database design follows these core principles:

1. **Single Source of Truth** - Each piece of data exists in exactly one location, eliminating duplication and inconsistency
2. **Student-Centric Design** - The `tribal_id` serves as the natural key for student identity, analogous to a Social Security Number within the organization
3. **Human-Readable Identifiers** - Application keys use a `YYYY-NNN` format (e.g., "2025-001") for staff-friendly reference
4. **Audit Trail** - Timestamps and user references track who made changes and when
5. **Flexibility** - JSON fields allow structured but adaptable data where appropriate

### 5.2 Current State: Monolithic Table

The existing database structure consists of a single `scholarship_applications` table containing 275+ fields. This monolithic design:

- Stores all data in one table without proper normalization
- Duplicates student information across multiple applications
- Makes lifetime tracking difficult and error-prone
- Limits reporting and analysis capabilities
- Creates maintenance challenges as requirements evolve

### 5.3 Target State: Normalized Schema

The normalized design separates concerns into distinct tables with proper relationships:

#### Core Tables Overview

| Table | Purpose | Linked By |
|-------|---------|-----------|
| `students` | Student identity and lifetime tracking | `tribal_id` (primary identifier) |
| `applications` | Individual scholarship applications | `tribal_id` (person) + `application_key` (app identifier) |
| `student_financial_tracking` | Award records for financial limits | `tribal_id` + `application_key` |
| `application_files` | Document attachments | `application_key` or `tribal_id` (profile files) |
| `verification_templates` | Application verification workflow | `application_key` |
| `historical_applications` | Imported paper records | `tribal_id` |
| `users` | System authentication | Has role-based permissions |

#### Entity Relationship Diagram (Text Description)

```
                    TRIBAL_ID links person-related data
                              |
+-----------------------------+-----------------------------+
|                             |                             |
v                             v                             v
STUDENTS               APPLICATIONS              HISTORICAL_APPLICATIONS
(tribal_id)      (tribal_id, application_key)        (tribal_id)
                              |
                              |
                    APPLICATION_KEY links application-related data
                              |
+-----------------------------+-----------------------------+
|                             |                             |
v                             v                             v
APPLICATION_FILES    VERIFICATION_TEMPLATES         BOARD_VOTES
(application_key)       (application_key)        (application_key)


STUDENT_FINANCIAL_TRACKING uses BOTH:
- tribal_id (links to person)
- application_key (links to specific application)

USERS (admin, staff, board_member) ---- creates/verifies records throughout system
```

### 5.4 Key Identifier Strategy

The system uses two meaningful identifiers rather than arbitrary database IDs for linking records:

#### Tribal ID (`tribal_id`) - Person Identifier
- **Purpose:** Permanent, unique identifier for each tribal member
- **Source:** Externally assigned by the tribe's enrollment office (not generated by this system)
- **Characteristics:** Never changes, already in the 800s for new registrations
- **Scope:** Links ALL student-related data across the system
- **Usage:** Primary key for student identity, used in:
  - `students` table (unique identifier)
  - `applications` (links application to person)
  - `student_financial_tracking` (links awards to person)
  - `historical_applications` (links imported records to person)

#### Application Key (`application_key`) - Application Identifier
- **Purpose:** Human-readable identifier for staff reference
- **Source:** Generated by this system upon application submission
- **Scope:** Links ALL application-related data
- **Usage:** Primary key for application identity, used in:
  - `applications` table (unique identifier)
  - `historical_applications` table (unique identifier)
  - `application_files` (links files to application)
  - `verification_templates` (links verification to application)
  - `board_votes` (links votes to application)
  - `student_financial_tracking` (links awards to specific application)

**Two Application Key Formats:**

| Type | Format | Example | Generation |
|------|--------|---------|------------|
| Digital Applications | `YYYY-NNN` | "2025-001", "2025-042" | Automatic, sequential within year |
| Historical Applications | `HIST-YYYY-NNN` | "HIST-2020-001", "HIST-2018-015" | Automatic when staff imports historical data |

**Why Historical Applications Need Keys:**
- Allows file attachments to historical applications (scanned paper records)
- Required for `student_financial_tracking` records (links award to specific application)
- Enables consistent linking across all application-related tables
- The `HIST-` prefix clearly distinguishes imported records from digital submissions

#### Design Rationale

This approach uses **meaningful identifiers** rather than arbitrary auto-increment IDs:

| Identifier | Who Assigns It | What It Links | Example |
|------------|---------------|---------------|---------|
| `tribal_id` | Tribe enrollment office | All person-related records | `847` |
| `application_key` | Our system | All application-related records | `2025-042` |

**Why not use auto-increment `student_id` foreign keys?**
- tribal_id already uniquely identifies the person
- Staff recognizes tribal_id immediately (meaningful)
- Eliminates unnecessary indirection
- Simpler queries without extra joins

**Note:** Tables still have auto-increment `id` primary keys for Rails compatibility, but relationships are built on tribal_id and application_key.

### 5.5 Field Compatibility Strategy

To ensure the existing application form continues functioning during the transition:

- All 275+ application fields retain their original names
- Form submission creates records in the new structure without changes to the form itself
- The existing field `student_id` (school-issued ID number) is renamed to `school_issued_student_id` for clarity - this is just form data the student enters (their university ID number), not a database relationship

---

## 6. Core System Components

### 6.1 Application Submission System

#### Student-Facing Form

The application form captures comprehensive information across multiple sections:

**Personal Information (~25 fields)**
- Name, date of birth, tribal enrollment
- Contact information and preferred communication method
- Permanent and school addresses

**Education History (~30 fields)**
- Previous colleges attended
- Degrees earned with dates
- High school information

**Current College Details (~15 fields)**
- Institution name and contact information
- Financial aid office details
- Enrollment status and program

**Academic Goals (~10 fields)**
- Degree program and field of study
- Expected graduation date
- Career objectives

**Financial Data (~100+ fields)**
- Budget Forecast (student estimate)
- Financial Needs Analysis fields (school-verified)
- Semester-by-semester breakdown of resources and expenses

**Supporting Documents**
- FAFSA documentation
- Transcripts (categorized by semester)
- Course schedules
- Acceptance letters

**Release Forms (~8 fields)**
- Photo release authorization
- Parental/guardian consent (if applicable)
- ARPA authorization (for federal funding)

#### Form Processing Workflow

```
Student submits application
         |
         v
System validates required fields
         |
         v
Find or create student record (by tribal_id)
         |
         v
Generate application_key (YYYY-NNN)
         |
         v
Create application record linked to student
         |
         v
Process file uploads (attach to application)
         |
         v
Create verification template (empty, pending)
         |
         v
Queue FNA request email to school
         |
         v
Send confirmation email to student
         |
         v
Display confirmation with application_key
```

### 6.2 Student Profile System

#### Profile Components

Each student profile provides a comprehensive view:

**Identity Section**
- Personal information (name, DOB, contact)
- Tribal enrollment details
- Primary identifier (tribal_id)

**Lifetime Financial Summary**
- Total undergraduate awards
- Total graduate awards
- Threshold warnings and remaining eligibility

**Application History**
- Current applications with status
- Historical applications (digital and imported)
- Verification status for each application

**Document Repository**
- Files from all applications (organized by type and date)
- Profile-specific documents
- Quick access to transcripts and key documents

**Award History**
- Year-by-year award breakdown
- Semester distribution
- Award types (regular, ARPA)

#### Historical Data Import

For transitioning paper records:

```
Staff accesses student profile (or creates new)
         |
         v
Opens "Add Historical Application" form
         |
         v
Enters minimal required data:
- Application year
- School name
- Amount requested
- Amount earned
- Award type
         |
         v
System creates historical_application record
         |
         v
Updates student lifetime totals
         |
         v
Links via tribal_id for future digital applications
```

### 6.3 Verification Workflow System

#### Web-Based Verification Interface

The verification system provides staff with a unified view of all applications requiring review:

**Bulk Verification View (Default)**
- Table showing all NON-ARCHIVED applications by default
- All students displayed by default (no student filter applied)
- Ordered by application submission date (oldest first)
- Expected volume: 50-100 applications per application window
- Inline status indicators for each verification item
- Progress tracking (not started, in progress, completed)
- Filter and sort capabilities
- Auto-save as staff completes items
- Toggle: "Show Current" (default) | "Show Archived"

**Individual Application Verification**
- Detailed checklist for single application
- Document review integration
- Staff notes section
- Award amount entry
- Final completion action

#### Verification Workflow Navigation

**Access from Student Profile:**

| User Action | System Behavior |
|-------------|-----------------|
| Click current application's verification link | Opens verification template for ONLY that application |
| "Show all current" button appears | Click to expand view to ALL current (non-archived) verification templates |
| Click archived application's verification link | Opens verification template for ONLY that archived application |
| "Show all archived" button appears | Click to expand view to ALL archived verification templates |

**Archived Template Editing:**
- Archived verification templates are EDITABLE by default (not read-only)
- Alternative implementation: Easy toggle to enable editing on archived templates
- Rationale: Staff may need to correct historical records or add notes

**Access from Verification Workflow Page:**

| Setting | Default Behavior |
|---------|------------------|
| Application filter | Non-archived (current) applications only |
| Student filter | All students (no filter) |
| Sort order | By submission date (oldest first) |
| Toggle available | Switch between current/archived views |

#### Search Functionality

**Two Search Modes:**

| Button | Behavior |
|--------|----------|
| **"Find in All"** | Searches full list, scrolls to and highlights the matching student's template WITHOUT hiding other templates |
| **"Isolate"** | Shows ONLY the searched student's template, hides all other templates from view |

**Search Fields:**
- Tribal ID lookup
- Application Key lookup (YYYY-NNN or HIST-YYYY-NNN format)

#### Progress Filtering (Prototype Feature - Future Implementation)

**Planned Capability:**
- Filter by verification progress status
- "Show applications not yet at [milestone]" - displays applications before a certain progress point
- "Show applications at or beyond [milestone]" - displays applications that have completed FNA or beyond
- Multiple status markers may be highlighted based on the selected filter threshold

**Implementation Status:** Deferred for prototype/later development once verification workflow structure is finalized

#### Verification Checklist Items

Standard verification includes:

1. Tribal ID verified against enrollment records
2. Transcripts received and reviewed
3. FAFSA documentation reviewed
4. Enrollment status confirmed
5. GPA requirements verified
6. Course load meets minimum
7. Financial Needs Analysis calculated
8. Recommendation for award amount

#### Integration with Financial Tracking

When staff completes verification and enters award amounts:

```
Staff enters award amounts:
- amount_awarded (regular scholarship)
- arpa_amount_awarded (ARPA federal funding)
         |
         v
System creates StudentFinancialTracking record
         |
         v
Updates student lifetime totals:
- total_undergrad_awarded (if undergraduate)
- total_grad_awarded (if graduate)
         |
         v
Checks threshold warnings
         |
         v
Displays updated financial status
```

### 6.4 File Management System

#### File Categories

Documents are categorized for organization:

| Category | Description | Typical Source |
|----------|-------------|----------------|
| `fafsa` | FAFSA documentation | Student upload |
| `transcript_fall` | Fall semester transcript | Student upload |
| `transcript_spring` | Spring semester transcript | Student upload |
| `course_schedule` | Current course schedule | Student upload |
| `acceptance_letter` | College acceptance | Student upload |
| `other` | Miscellaneous documents | Student upload |

#### Dual Attachment Model

Files can be attached at two levels:

1. **Application-Specific** - Documents tied to a particular application
   - Semester transcripts for that application period
   - FAFSA for the application year

2. **Profile-Specific** - Documents tied to the student across applications
   - High school transcripts
   - Identification documents
   - General records

#### Admin File Management

Staff capabilities include:

- View files organized by category and date
- Download or view inline (PDF preview)
- Remove duplicate files
- Required file checklist per application
- Missing file alerts in verification workflow

---

## 7. User Roles and Authentication

### 7.1 Three-Tier Role System

The application implements three distinct roles with standardized permissions:

#### Admin Role (3-4 Accounts)

**Full system access including:**
- Complete application management (CRUD operations)
- Student profile management
- User account creation, modification, and deletion
- System configuration and settings
- All verification workflow capabilities
- Board decision oversight and override
- Full audit log access

**Distinguishing capabilities:**
- Only role that can manage other user accounts
- Can modify system-wide settings
- Can override board decisions if needed

#### Staff Role (4 Accounts)

**Full operational access including:**
- Complete application management
- Student profile management
- Verification workflow operation
- Award amount entry and modification
- Historical application import
- File management
- View board feedback and votes (read-only)

**Distinguishing capabilities:**
- Primary verification workflow operators
- Cannot create or modify user accounts
- Cannot change system settings

#### Board Member Role (8-10 Accounts)

**Limited review portal access:**
- Read-only application access
- Read-only student profile access
- Submit votes (approve/deny/abstain)
- Submit feedback with votes (visible to staff)
- View documents and verification status

**Restrictions:**
- Cannot modify any application or student data
- Cannot upload or delete files
- Cannot see other board members' votes
- No export capabilities

### 7.2 Authentication System

#### Account Management
- Email-based authentication
- Secure password requirements
- Password reset via email
- Session management with automatic logout
- Single role per account (no mixed roles)

#### Session Security
- Configurable session timeout
- Secure session storage
- Protection against session fixation
- CSRF token validation

### 7.3 Authorization Implementation

Authorization is enforced at multiple levels:

**Controller Level**
```ruby
# Conceptual authorization checks
before_action :authenticate_user!              # Require login
before_action :authorize_admin!                # Admin only
before_action :authorize_staff_or_admin!       # Staff and admin
before_action :authorize_board_member!         # Board portal access
```

**View Level**
- Conditional rendering based on user role
- Appropriate navigation for each role
- Action buttons shown/hidden based on permissions

**Model Level**
- Validation of authorized operations
- Tracking of who made changes
- Audit trail for sensitive operations

---

## 8. Application Lifecycle Management

### 8.1 10-Month Application Lifecycle

All applications follow a 10-month lifecycle starting from the **application deadline date**, not the submission date.

#### Timeline Illustration

```
August 21        September 1                              July 1
    |                 |                                      |
    v                 v                                      v
 [Submit]         [Deadline]                            [Archive]
    |                 |                                      |
    |<-- Early -->|   |<------------ 10 Months ------------>|
    |  Submission     |                                      |
    |                 |                                      |
Staff sees application immediately,                   Auto-archive or
but lifecycle starts at deadline                      manual finalization
```

**Key Concepts:**

- **Early Submissions** - Applications submitted before deadline are visible immediately to staff but lifecycle countdown starts at deadline
- **Lifecycle Duration** - 10 months from deadline date covers the full academic year
- **Archive Trigger** - Either automatic (10 months elapsed) or manual (staff marks complete)

### 8.2 Application Status Progression

Applications move through defined statuses:

| Status | Description | Triggered By |
|--------|-------------|--------------|
| `submitted` | Initial state after submission | Student action |
| `under_staff_review` | Staff has begun verification | Staff action |
| `ready_for_board` | Verification complete, awaiting board | Staff action |
| `board_voting_open` | Board members can vote | Voting period start |
| `board_voting_complete` | All votes received | All votes submitted |
| `staff_final_decision` | Staff reviewing board feedback | Staff action |
| `awarded` | Application approved with award | Staff action |
| `denied` | Application denied | Staff action |

### 8.3 Archiving Methods

#### Automatic Archiving

- **Trigger:** 10 months after deadline date
- **Condition:** Application not manually finalized
- **Use Case:** Applications that fell through, incomplete submissions, withdrawn applications

#### Manual Finalization (Preferred)

- **Trigger:** Staff explicit action
- **Options:**
  - "Finalized and Paid" - Award fully disbursed
  - "Finalized and Denied" - Application denied, process complete
- **Effect:** Immediately archives regardless of time elapsed

### 8.4 Deadline Configuration

#### Application Cycles

Each scholarship cycle is configured with:

```
Application Cycle Configuration:
- Cycle name (e.g., "Fall 2025")
- Application deadline (submission cutoff)
- Cycle start date (lifecycle begins)
- Transcript deadline - Semester 1
- Transcript deadline - Semester 2
- Board voting start date
- Board voting end date
```

#### Transcript Requirements

Students must submit transcripts to receive subsequent payments:

- Fall transcript required before spring semester payment
- Configurable deadline per cycle
- Staff can mark requirement as satisfied
- Missing transcript blocks second payment

---

## 9. Financial Tracking System

### 9.1 Award Threshold System

#### Lifetime Award Limits (Updated January 2026)

The system tracks lifetime awards against a **tiered allocation system**:

| Component | Amount | Notes |
|-----------|--------|-------|
| **Total Lifetime Cap** | $24,000 | Maximum across all education levels |
| **Undergraduate Allocation** | $15,000 | Base allocation for undergrad |
| **Graduate Base Allocation** | $9,000 | Guaranteed graduate allocation |
| **Graduate Effective Allocation** | Up to $24,000 | Base $9k + unused undergrad funds |

**Key Rules:**
1. **Total Cap:** No student can receive more than $24,000 lifetime across all awards
2. **Undergrad First:** Undergrad allocation is capped at $15,000
3. **Grad Rollover:** Unused undergrad funds roll over to increase graduate allocation
4. **Example:** Student uses $12k undergrad → Graduate effective = $9k base + $3k unused = $12k available for grad

#### ARPA vs Regular Awards

**Critical Distinction:**
- **Regular Awards (HE):** Count toward lifetime limits ($24k total)
- **ARPA Awards:** Tracked but do NOT count toward lifetime limits
- **Combined Awards:** Split into Regular + ARPA portions; only Regular counts toward limits

**Implementation Details:**
- ARPA is a temporary federal funding program with separate tracking requirements
- When entering a Combined award, staff specifies Regular and ARPA amounts separately
- System creates two financial tracking records for Combined awards (one Regular, one ARPA)
- Only the Regular portion affects the student's lifetime totals
- Student profiles display ARPA totals separately for visibility

**Important:** These limits are **informational, not enforcement**. Staff and board can approve awards exceeding limits when justified, with appropriate documentation.

### 9.2 Three Financial States

#### 1. Current Application (Unverified)

- **Status:** Application submitted, not yet verified
- **Display:** Shows as "Possible Award" on student profile
- **Effect:** NOT included in lifetime totals until finalized

#### 2. Verified Application (Approved)

- **Status:** Verification complete, board approved
- **Display:** Included in lifetime totals immediately
- **Effect:** Updates student's total_undergrad_awarded or total_grad_awarded

#### 3. Disbursed Award

- **Status:** Funds transferred
- **Display:** Tracked in financial tracking table with semester breakdown
- **Effect:** Already in lifetime totals, marked as disbursed

### 9.3 Warning System

The system provides visual warnings at key points:

**Yellow Warning (80% Threshold)**
- Displayed when student has received 80%+ of limit
- Example: $12,000+ for undergraduate

**Red Warning (Would Exceed)**
- Displayed when current application would exceed limit
- Shows exact overage amount

**Display Example:**
```
Student: Jane Doe (Tribal ID: 12345)
Lifetime Total: $20,000 / $24,000 (83% used)
  Undergraduate: $14,000 / $15,000 allocation
  Graduate Base: $6,000 / $9,000 base allocation
  Graduate Effective: $6,000 / $10,000 ($9k base + $1k unused undergrad)

WARNING: Approaching lifetime limit ($4,000 remaining)

Current Application Request: $5,000
ALERT: This application would exceed lifetime limit by $1,000

Board Decision: Approve anyway | Deny | Adjust award amount
```

### 9.4 Override Capability

When limits would be exceeded:

1. System displays clear warning with context
2. Staff/board can choose to:
   - Approve full amount (override limit)
   - Approve partial amount (stay within limit)
   - Deny citing limit as reason
3. Override is recorded with justification
4. Audit trail captures decision

---

## 10. Email and Notification System

### 10.1 Email Infrastructure

#### Sender Address
All system emails originate from: `scholarships@sitkatribe-nsn.gov`

#### Email Service
Integration with transactional email service (SendGrid, Postmark, or similar) providing:
- High deliverability rates
- Delivery tracking (sent, delivered, opened, bounced)
- Webhook integration for reply detection
- SPF, DKIM, DMARC authentication

#### Business Hours Scheduling
Emails to educational institutions are sent only during business hours:
- **Hours:** 8:00 AM - 5:00 PM Alaska Time
- **Days:** Monday through Friday
- **Timezone:** America/Anchorage
- **After Hours:** Queued for next business morning

### 10.2 Automated Email Workflows

#### FNA Request (School Verification)

Triggered when student submits application:

```
Application submitted
         |
         v
Check business hours
         |
    +----+----+
    |         |
  Yes        No
    |         |
    v         v
Send       Queue for
immediately  next morning
    |         |
    +----+----+
         |
         v
Email to school's financial aid office:
- Student identification
- Secure upload link for FNA
- PDF download option
- Contact information
         |
         v
Track delivery status
         |
         v
If no response after 7 days:
- Update status to "student_followup"
- Send email to student with PDF copy
- Request student hand-deliver to school
```

#### Award Notification

Triggered when staff sends award decision:

```
Staff initiates award notification
         |
         v
Select template or customize
         |
         v
Merge student-specific data
         |
         v
Send to student email
         |
         v
Update application:
- award_notification_sent = true
- award_notification_sent_at = timestamp
         |
         v
Create email log record
         |
         v
Track delivery and opens
```

### 10.3 Email Template System

Staff can manage templates with variable substitution:

**Available Variables:**
- `{student_first_name}`, `{student_last_name}`
- `{application_key}`
- `{amount_awarded}`
- `{deadline_date}`
- `{school_name}`
- `{upload_link}`

**Template Categories:**
- FNA Request
- Transcript Request
- Award Notification
- Status Update
- Document Request
- General Communication

### 10.4 Secure Upload Portal

#### School FNA Upload

Unique URL format: `https://[domain]/fna-submit/{unique_token}`

Features:
- Displays student identification (read-only)
- Web form for FNA data entry
- PDF upload option
- Single-use token (expires after submission or 30 days)
- IP address logging for security

#### Student Document Upload

Unique URL format: `https://[domain]/upload/{unique_token}`

Features:
- Pre-loaded document categories from request
- Multiple files per category
- File format validation
- Upload progress indicators
- Confirmation email upon completion

### 10.5 Global Notifications Center

#### Staff Notification System

All staff see the same notifications (not personalized):

**Notification Types:**
- New application submitted
- Document uploaded
- FNA submitted by school
- Email bounced
- Board voting complete
- Application archived

**Features:**
- Badge count in navigation
- "Currently viewing" indicator (shows when another staff member is viewing)
- Approve/dismiss workflow
- Audit log of all notifications

---

## 11. Implementation Phases

### 11.1 Phase Overview

The implementation is divided into 10 phases with clear dependencies:

| Phase | Description | Dependencies | Est. Sessions |
|-------|-------------|--------------|---------------|
| 1 | Database Foundation | None | 2-3 |
| 2 | Core Models | Phase 1 | 2-3 |
| 3 | Data Migration | Phases 1-2 | 2-3 |
| 4 | Student Profiles | Phases 1-3 | 3-4 |
| 5 | Core Application Features | Phases 1-4 | 4-5 |
| 6 | File Management | Phases 1-4 | 2-3 |
| 7 | Verification Workflow | Phase 5 | 4-5 |
| 8 | CSV Export & Reporting | Phase 7 | 2-3 |
| 9 | Testing & QA | Throughout | 2-3 |
| 10 | Documentation & Deployment | Final | 1-2 |

**Total Estimated Sessions:** 25-35

### 11.2 Phase 1: Database Foundation

**Objective:** Create all normalized database tables

**Deliverables:**
- Enhanced students table migration
- New applications table (275+ fields, identical names)
- Student financial tracking table
- Application files table
- Verification templates table
- Historical applications table
- Proper indexes and constraints

**Success Criteria:**
- All migrations run without errors
- Schema matches target design
- Old table remains intact (backup)

### 11.3 Phase 2: Core Models

**Objective:** Build model classes with associations

**Deliverables:**
- Student model (enhanced)
- Application model (new)
- StudentFinancialTracking model
- ApplicationFile model
- VerificationTemplate model
- HistoricalApplication model

**Key Model Methods:**
- `Application.generate_application_key` - Automatic key generation
- `Student.lifetime_undergrad_total` - Award calculation
- `Student.threshold_warning?` - Limit checking

**Success Criteria:**
- All associations work correctly
- Validations pass tests
- Model methods return expected values

### 11.4 Phase 3: Data Migration

**Objective:** Migrate existing data to new structure

**Deliverables:**
- Data analysis and quality report
- Migration rake task
- Edge case handling (missing tribal IDs, duplicates)
- Verification scripts

**Migration Process:**
1. Analyze existing data for quality issues
2. Extract unique students from applications (group by tribal_id)
3. Create student records
4. Migrate applications to new table
5. Generate application keys
6. Verify counts and relationships

**Success Criteria:**
- All data migrated successfully
- No data loss
- Relationships correct
- Error report for manual review

### 11.5 Phase 4: Student Profile Pages

**Objective:** Build comprehensive student profile interface

**Deliverables:**
- Student list view with search/filter
- Student profile page with:
  - Identity information
  - Lifetime financial summary
  - Application history (current + historical)
  - Document repository
  - Verification history
- Historical import interface

**Success Criteria:**
- Staff can view complete student history
- Historical import creates records correctly
- Financial tracking displays accurately

### 11.6 Phase 5: Core Application Features

**Objective:** Rebuild application submission and admin review

**Deliverables:**
- Updated application submission form
- Admin application review interface
- Status management functionality
- Dashboard statistics
- Application status checking (student-facing)

**Success Criteria:**
- Students can submit applications
- Applications link to student profiles
- Staff can review and update applications
- Dashboard shows accurate statistics

### 11.7 Phase 6: File Management

**Objective:** Implement categorized file system

**Note:** Can run parallel with Phase 5

**Deliverables:**
- Categorized upload interface
- Admin file management tools
- Student profile file display
- Required file tracking

**Success Criteria:**
- Files properly categorized
- Staff can manage files easily
- Required file tracking works

### 11.8 Phase 7: Verification Workflow

**Objective:** Build web-based verification system

**Deliverables:**
- Bulk verification interface
- Individual application verification
- Auto-save functionality
- Award amount entry
- Financial integration
- Board member portal
- Voting system

**Success Criteria:**
- Staff can verify applications efficiently
- Progress auto-saves reliably
- Financial tracking updates correctly
- Board members can vote

### 11.9 Phase 8: CSV Export & Reporting

**Objective:** Implement export functionality

**Deliverables:**
- Single application export
- Bulk application export
- Student history export
- Verification template exports
- Export service classes

**Success Criteria:**
- CSV exports generate correctly
- Data properly formatted
- Performance acceptable for large datasets

### 11.10 Phase 9: Testing & QA

**Objective:** Comprehensive testing coverage

**Ongoing throughout all phases**

**Deliverables:**
- Model tests (validations, associations)
- Controller tests (all actions)
- Integration tests (workflows)
- System tests (UI)
- Performance testing

**Success Criteria:**
- Test coverage > 80%
- No critical bugs
- Performance acceptable for 1000+ applications

### 11.11 Phase 10: Documentation & Deployment

**Objective:** Prepare for production

**Deliverables:**
- Code documentation
- User guides (staff, admin, student)
- Deployment procedures
- Rollback plan
- Old table cleanup

**Success Criteria:**
- System fully documented
- Ready for production deployment
- Training materials prepared

---

## 12. Security Considerations

### 12.1 Current Security Measures

The application leverages Rails' built-in security features:

- **CSRF Protection** - Token validation on all forms
- **SQL Injection Prevention** - Parameterized queries via ActiveRecord
- **XSS Protection** - Automatic output escaping in views
- **Secure Sessions** - Encrypted, httponly cookies
- **Strong Parameters** - Whitelisted parameter handling

### 12.2 Planned Security Enhancements

#### Authentication Security
- Password complexity requirements
- Account lockout after failed attempts
- Secure password reset workflow
- Session timeout configuration

#### Data Protection
- Sensitive field encryption at rest (tribal_id, financial data)
- Audit logging for all data access
- Role-based access control enforcement

#### Email Security
- SPF, DKIM, DMARC authentication
- Bounce monitoring and blacklist alerts
- Secure token generation for upload portals

### 12.3 Compliance Considerations

- **Data Privacy** - Sensitive tribal member information requires appropriate handling
- **Audit Trail** - Complete record of who accessed/modified data
- **Retention Policy** - Define data retention periods (to be determined)

### 12.4 Security Review Status

Security implementation will be expanded in future phases. Current focus is on leveraging Rails defaults with planned enhancements for:
- Multi-factor authentication
- Advanced audit logging
- Field-level encryption
- Regular security scanning with Brakeman

---

## 13. Deployment Strategy

### 13.1 Target Environment

**Server:** Ubuntu server (specific version TBD)
**Platform:** AWS container-based deployment (specific services TBD)
**Database:** PostgreSQL (managed service or self-hosted TBD)

### 13.2 Containerization

The application will be containerized using Docker:

- Production image built from development environment
- Multi-stage builds for optimized image size
- Environment-specific configuration via environment variables
- Secrets management (approach TBD)

### 13.3 Deployment Tools

**Kamal** - Rails' official deployment tool for containerized applications:
- Zero-downtime deployments
- Rolling updates
- Automatic rollback capability
- Built-in health checks

### 13.4 Deployment Checklist (To Be Expanded)

- [ ] Production database provisioned
- [ ] SSL certificate configured
- [ ] Email service credentials configured
- [ ] File storage configured (Active Storage)
- [ ] Environment variables set
- [ ] Backup procedures tested
- [ ] Monitoring configured
- [ ] Rollback procedure documented

---

## 14. Open Questions

### 14.1 Business Logic Questions

1. ~~**Award Limit Carryover**~~ **RESOLVED (January 2026):** Unused undergraduate funds DO roll over to graduate allocation. Total lifetime cap is $24,000. See Section 9.1 for full details.

2. **Vote Modification Rules** - Can board members change votes before the deadline? Current assumption: yes, until voting period ends.

3. **Data Retention** - How long should archived applications be retained? Indefinitely assumed.

### 14.2 Technical Decisions

1. **Email Service Selection** - SendGrid vs Postmark vs other? Selection pending.

2. **File Storage** - Local Active Storage disk vs AWS S3 vs other cloud storage? TBD based on deployment.

3. **Exact AWS Services** - EC2 vs ECS vs EKS? To be determined based on requirements and budget.

### 14.3 Future Enhancements (Out of Scope)

Items identified but not included in current scope:

- Multi-factor authentication
- Native mobile application
- SMS notifications
- Real-time collaboration features
- Advanced analytics dashboard
- External API integrations

---

## 15. Appendix: Database Schema Reference

### 15.1 Students Table

```sql
students
  - id (primary key)
  - tribal_id (unique, indexed) -- Natural key for person
  - first_name, last_name, middle_initial
  - date_of_birth, place_of_birth
  - email_address, preferred_contact, permanent_phone
  - mailing_address_permanent, city, state, zip_code
  - tribe_enrolled
  - total_undergrad_awarded (decimal)
  - total_grad_awarded (decimal)
  - lifetime_award_notes (text)
  - close_to_undergrad_limit (boolean)
  - close_to_grad_limit (boolean)
  - created_at, updated_at
```

### 15.2 Applications Table

```sql
applications
  - id (primary key)
  - application_key (unique, indexed) -- "YYYY-NNN" format, links to files/verification/votes
  - tribal_id (indexed) -- Links to students table (person identifier)
  - application_year, application_type (enum: digital, historical_import)
  - status, board_status
  - [ALL 275+ form fields - names unchanged]
  - school_issued_student_id -- University's ID for student (form data, not a relationship)
  - amount_requested, amount_awarded, arpa_amount_awarded
  - application_cycle_id (foreign key -> application_cycles)
  - submitted_at, lifecycle_start_date, lifecycle_end_date
  - finalized_at, finalization_status
  - archived (boolean)
  - fna_request_sent_at, fna_request_status
  - award_notification_sent, award_notification_sent_at
  - threshold_override (boolean)
  - override_justification (text)
  - created_at, updated_at
```

### 15.3 Student Financial Tracking Table

```sql
student_financial_tracking
  - id (primary key)
  - tribal_id (indexed) -- Links to students table (person identifier)
  - application_key (indexed) -- Links to applications table
  - award_year
  - award_type (enum: regular, arpa, combined)
  - semester_1_amount, semester_2_amount
  - total_award_amount
  - award_source (enum: verification_workflow, manual_entry)
  - is_current_application (boolean)
  - notes (text)
  - created_at, updated_at
```

### 15.4 Application Files Table

```sql
application_files
  - id (primary key)
  - application_key (indexed, nullable) -- Links to applications table
  - tribal_id (indexed, nullable) -- Links to students table (for profile-attached files)
  - file_category (enum: fafsa, transcript_fall, transcript_spring,
                   course_schedule, acceptance_letter, other)
  - file_name, file_description
  - attachment_location (enum: application, student_profile)
  - uploaded_at
  - [Active Storage attachment]
  - created_at, updated_at
```

### 15.5 Verification Templates Table

```sql
verification_templates
  - id (primary key)
  - application_key (unique, indexed) -- Links to applications table
  - template_data (JSON) -- Verification checklist items
  - completion_status (enum: not_started, in_progress, completed)
  - verified_by_staff_id (foreign key -> users)
  - verification_started_at, verification_completed_at
  - notes (text)
  - created_at, updated_at
```

### 15.6 Historical Applications Table

```sql
historical_applications
  - id (primary key)
  - application_key (unique, indexed) -- "HIST-YYYY-NNN" format for historical imports
  - tribal_id (indexed) -- Links to students table (person identifier)
  - application_year, school_name
  - amount_requested, amount_earned
  - award_type (enum: regular, arpa, combined)
  - education_level (enum: undergraduate, graduate) -- For lifetime tracking
  - entry_date, entered_by_staff_id
  - notes (text)
  - created_at, updated_at
```

**Auto-Creation of Financial Tracking:**
When staff enters a historical application, the system automatically:
1. Generates `application_key` in `HIST-YYYY-NNN` format (e.g., "HIST-2020-001")
2. Creates a corresponding `student_financial_tracking` record with:
   - `tribal_id` from the historical application
   - `application_key` linking to this historical application
   - `award_year` from application_year
   - `total_award_amount` from amount_earned
   - `award_source = 'historical_import'`
3. Updates the student's lifetime totals (`total_undergrad_awarded` or `total_grad_awarded`)

This ensures all historical paper records contribute to accurate lifetime award tracking.

### 15.7 Users Table

```sql
users
  - id (primary key)
  - email (unique)
  - encrypted_password
  - role (enum: admin, staff, board_member)
  - first_name, last_name
  - active (boolean)
  - last_login_at
  - created_by_admin_id (foreign key -> users)
  - created_at, updated_at
```

### 15.8 Board Votes Table

```sql
board_votes
  - id (primary key)
  - application_key (indexed) -- Links to applications table
  - board_member_id (foreign key -> users)
  - vote (enum: approve, deny, abstain)
  - feedback (text)
  - vote_draft (boolean)
  - voted_at
  - locked (boolean)
  - created_at, updated_at

  -- Unique constraint: (application_key, board_member_id)
```

### 15.9 Application Cycles Table

```sql
application_cycles
  - id (primary key)
  - cycle_name
  - application_deadline
  - cycle_start_date
  - cycle_type (enum: yearly, semester, quarter)
  - transcript_deadline_semester_1
  - transcript_deadline_semester_2
  - board_voting_start_date, board_voting_end_date
  - active (boolean)
  - created_at, updated_at
```

### 15.10 Email Templates Table

```sql
email_templates
  - id (primary key)
  - template_name (unique)
  - template_category (enum: fna_request, transcript_request,
                       award_notification, status_update,
                       document_request, general)
  - subject_line (text)
  - body_text (text)
  - active (boolean)
  - created_by_admin_id (foreign key -> users)
  - created_at, updated_at
```

### 15.11 Email Logs Table

```sql
email_logs
  - id (primary key)
  - application_key (indexed) -- Links to applications table
  - tribal_id (indexed) -- Links to students table
  - email_type (enum)
  - template_id (foreign key -> email_templates)
  - sent_to, sent_from
  - subject_line (text)
  - sent_at, scheduled_for
  - delivery_status (enum: queued, sent, delivered, opened,
                     bounced, failed, replied)
  - delivered_at, opened_at, bounced_at, bounce_reason, replied_at
  - sent_by_staff_id (foreign key -> users)
  - created_at, updated_at
```

### 15.12 Notifications Table

```sql
notifications
  - id (primary key)
  - notification_type (enum)
  - application_key (indexed, nullable) -- Links to applications table
  - tribal_id (indexed, nullable) -- Links to students table
  - related_email_id (foreign key -> email_logs, nullable)
  - title, message (text)
  - priority (enum: low, normal, high, critical)
  - status (enum: pending, viewed, approved, dismissed)
  - currently_viewing_by (foreign key -> users, nullable)
  - viewed_by_staff_id, viewed_at
  - approved_by_staff_id, approved_at
  - created_at, updated_at
```

### 15.13 System Settings Table

```sql
system_settings
  - id (primary key)
  - setting_key (unique)
  - setting_value (JSON)
  - description (text)
  - updated_by_admin_id (foreign key -> users)
  - created_at, updated_at

-- Example records:
-- {setting_key: 'undergrad_limit', setting_value: 15000}
-- {setting_key: 'grad_limit', setting_value: 9000}
-- {setting_key: 'limit_model', setting_value: 'separate'}
```

### 15.14 Secure Upload Tokens Table

```sql
secure_upload_tokens
  - id (primary key)
  - token (unique, 32+ character cryptographic random)
  - application_key (indexed) -- Links to applications table
  - tribal_id (indexed, nullable) -- Links to students table
  - token_type (enum: fna_school, document_student,
                transcript_student, general)
  - requested_categories (JSON array)
  - single_use (boolean)
  - used (boolean), used_at
  - expires_at
  - created_at, updated_at
```

### 15.15 Schools Table

```sql
schools
  - id (primary key)
  - school_name
  - school_type (enum: university, community_college,
                 vocational, high_school)
  - financial_aid_office_email, financial_aid_office_phone
  - address, city, state, zip_code
  - verified (boolean)
  - verified_at, verified_by_staff_id
  - notes (text)
  - created_at, updated_at
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Sept 2025 | Ethan Fitzsimmons | Initial planning document |
| 1.1 | Dec 2025 | Ethan Fitzsimmons | Environment setup and verification |
| 2.0 | Dec 2025 | Ethan Fitzsimmons | Comprehensive RFC (this document) |
| 2.1 | Jan 2026 | Claude Code Session | Updated Section 9 (Financial Tracking): Corrected lifetime limits to $24k total with rollover system; Added ARPA vs Regular award distinction; Combined awards split tracking |
| 2.2 | Jan 2026 | Claude Code Session | Major updates: FNA removal, Historical Applications overhaul, File upload restructure, Form improvements |

---

## Recent Changes Log (January 2026)

### FNA Removal (Education Committee Approved)
The Financial Needs Analysis (FNA) requirement has been **completely removed** from the system:
- FNA form fields remain in database but are unused (reversible if needed)
- FNA warning boxes removed from application form header
- FNA upload section removed from file uploads
- FNA display sections removed from admin views
- FNA-related strong params removed from controllers
- Student-entered Budget Forecast section **remains intact**

### Historical Applications Overhaul
Simplified the historical import interface to essential fields only:
- **Required Fields:** Tribal ID, First Name, Last Name, Application Year, Amount (HE), Education Level
- **Optional Fields:** School Name, Notes
- **Removed:** Award Type selection, Original Reference, App Key display, Entry Date, ARPA amounts
- **Auto-Generation:** Application key generated automatically as `HIST-YYYY-NNN`
- **Student Creation:** If no student exists with the given Tribal ID, one is created automatically

### Name Display Priority System
Implemented consistent name display logic across the system:
1. **First Priority:** Name from most recent digital Application (by created_at)
2. **Second Priority:** Name from most recent HistoricalApplication (by application_year)
3. **Fallback:** Student record's own name fields or the current record's name

This ensures the most up-to-date name is always displayed, regardless of data source.

### File Upload Restructure
Reorganized file uploads into separate categorized sections:
- **Transcripts:** Multiple files allowed, "Add Another" button
- **FAFSA:** Multiple files allowed, "Add Another" button
- **Acceptance Letters:** Multiple files allowed, "Add Another" button
- **Other Documents:** Multiple files with label text field for identification
- **FNA Section:** Removed entirely

### Form UX Improvements
- **Required Field Indicators:** Red asterisks (*) that disappear when field is filled
- **Optional Field Indicators:** Yellow circles (○) that disappear when field is filled
- **State Autocomplete:** Combo boxes with datalist for state selection
- **GPA Field:** Added to education plan section with 0.00-4.00 range
- **Responsive Behavior:** Stimulus controllers for dynamic indicator updates

### Ideas for Future Implementation
1. **Bulk Historical Import:** CSV upload for mass historical data entry
2. **Student Merge Tool:** Combine duplicate student records
3. **Award Letter Generation:** Automated PDF generation for award notifications
4. **Dashboard Enhancements:** Charts and visualizations for application statistics
5. **Email Notification System:** Automated status updates to students

---

*This RFC documents the complete technical specification for the STA Scholarship Application Management System. It serves as the authoritative reference for implementation, onboarding, and future development.*
