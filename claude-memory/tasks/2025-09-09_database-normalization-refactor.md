# Database Normalization Refactor - STA Scholarship Application System

**Task Created:** 2025-09-09  
**Status:** Planning Complete - Ready for Implementation  
**Estimated Timeline:** Extended timeline - Comprehensive database overhaul with multiple phases  
**Priority:** High - Core architecture improvement and foundation for all future work

## Project Overview

Complete database restructure from monolithic `scholarship_applications` table (275+ fields verified from schema) into a proper normalized relational database structure. This is a comprehensive overhaul to create a solid foundation for all future development work.

### Core Design Principles
1. **Single Source of Truth** - Eliminate data duplication except for essential fields
2. **Student-Centric Design** - Use tribal_id as natural key for student identity (organizational equivalent of SSN)
3. **Application Tracking** - Use human-readable application_key for staff-friendly identification (e.g., "2025-001", "2025-002")
4. **Organized File Storage** - Categorized file uploads with clear admin visibility
5. **Field Name Consistency** - Keep field names the same so application forms don't need changes
6. **Development Freedom** - Not deployed/in use, so we can break functionality temporarily to rebuild properly

### Project Approach
- **Complete database overhaul** - Refactor majority/entire database structure
- **No functionality maintenance required** - Freedom to break and rebuild systems better
- **Foundation focus** - Get database to best possible state before building features
- **Progress reporting** - Working functionality is bonus, not requirement
- **Staff backup strategy** - Manual tribal_id entry moves applications to correct student profiles

## Current State Analysis

### Existing Monolithic Table
- **Table:** `scholarship_applications` (275+ fields verified from schema)
- **Key Fields:** id (auto-increment), created_at, updated_at, tribal_id (student_id field)
- **Existing Related Table:** `students` table already exists with basic financial tracking foundation
- **Data Categories:**
  - Personal Information (~25 fields: names, DOB, contact info)
  - Address Information (~12 fields: permanent and school addresses) 
  - Education History (~30 fields: previous colleges, degrees, dates)
  - Current College Details (~15 fields: college info, financial aid office)
  - Academic Goals (~10 fields: degree program, graduation date, field of study)
  - Financial Data (~100+ fields - Extensive FNA breakdown by semester for all funding sources)
  - Release Forms (~8 fields: photo, parental, ARPA authorization)
  - Enrollment Verification (~10 fields)
  - Administrative/Verification Data (~25 fields: amount_awarded, arpa_amount_awarded, board_status, etc.)
  - Staff Dashboard Tracking (verification workflow fields scattered throughout)

### Current Application Context
- **Paper-based system** - This website will be first digital transition
- **Historical data gap** - Years of paper applications need manual import capability
- **Mixed verification** - New applications will have workflow, old applications need manual entry
- **Dual award system** - Regular scholarships + ARPA federal funding (temporary program)

### Current Functionality to Rebuild
- Single-form submission (keep field names same)
- Admin application review interface  
- CSV export capabilities (currently broken)
- File upload system (currently basic Active Storage)
- Status management and tracking
- Student profile foundation (existing students table to expand)

## Target Database Schema

### New Table Structure

```ruby
# Core Tables - Enhanced Design
students (expand existing table)
  - id (primary key)
  - tribal_id (unique, natural key - organizational equivalent of SSN)
  - first_name, last_name, middle_initial
  - date_of_birth, place_of_birth
  - email_address, preferred_contact, permanent_phone
  - mailing_address_permanent, city, state, zip_code
  - tribe_enrolled
  - total_undergrad_awarded, total_grad_awarded (existing fields)
  - lifetime_award_notes (existing field)
  - close_to_undergrad_limit, close_to_grad_limit (existing boolean flags)
  - created_at, updated_at

applications
  - id (primary key)
  - application_key (human-readable: "2025-001", "2025-002" for staff clarity)
  - student_id (foreign key -> students)
  - application_year, application_type (enum: digital, historical_import)
  - status, board_status
  - [ALL form fields from current table - keep field names identical]
  - amount_requested, amount_awarded, arpa_amount_awarded
  - created_at, updated_at, submitted_at

student_financial_tracking (new table - separate from applications)
  - id (primary key)
  - student_id (foreign key -> students)
  - application_id (foreign key -> applications)
  - award_year
  - award_type (enum: regular, arpa, combined)
  - semester_1_amount, semester_2_amount
  - total_award_amount
  - award_source (enum: verification_workflow, manual_entry)
  - is_current_application (boolean - for threshold checking)
  - notes
  - created_at, updated_at

application_files
  - id (primary key) 
  - application_id (foreign key -> applications)
  - student_id (foreign key -> students - for profile-attached files)
  - file_category (enum: fafsa, transcript_fall, transcript_spring, course_schedule, acceptance_letter, other)
  - file_name, file_description
  - attachment_location (enum: application, student_profile)
  - uploaded_at
  - [Active Storage attachment]

verification_templates (staff workflow)
  - id (primary key)
  - application_id (foreign key -> applications)
  - template_data (JSON field for verification checklist items)
  - completion_status (enum: not_started, in_progress, completed)
  - verified_by_staff_id
  - verification_started_at, verification_completed_at
  - notes (text field for staff comments)
  - created_at, updated_at

# Historical Data Import Tables
historical_applications (for manual staff entry)
  - id (primary key)
  - student_id (foreign key -> students)
  - application_year, school_name
  - amount_requested, amount_earned
  - award_type (regular, arpa, combined)
  - entry_date, entered_by_staff_id
  - notes
  - created_at, updated_at
```

### Key Design Decisions

**Student Profile Fields (enhanced existing students table):**
- Personal identifiers (names, DOB, tribal_id) 
- Contact information (email, preferred_contact, permanent address)
- Tribal enrollment information
- Financial summary fields (total awards by education level)
- Lifetime tracking flags and notes

**Application Fields (keep all form fields in applications table):**
- ALL current form fields with identical names (for form compatibility)
- Financial data and semester breakdowns (FNA data stays here)
- Current college and academic information  
- Education history and goals
- Release form data
- Award amounts (amount_requested, amount_awarded, arpa_amount_awarded)
- Application type distinction (digital vs historical import)

**Financial Tracking Separation:**
- New `student_financial_tracking` table separate from applications
- Pulls verified amounts from verification workflow OR manual entry
- Tracks semester-by-semester awards
- Current application threshold checking (don't add to totals until verified)
- Supports both regular and ARPA funding pools

**File Storage Enhancement:**
- Dual attachment capability (application-specific OR student profile)
- Semester-specific transcript categorization (fall, spring, etc.)
- Staff file management with duplicate removal capability
- Student profile displays all files from applications plus profile-specific files

**Historical Data Bridge:**
- Manual import interface integrated into student profile pages
- Simplified data entry for paper application history
- Creates student profiles in anticipation of future digital applications
- Links historical and digital data through tribal_id matching

## Implementation Plan - Comprehensive Overhaul

**Total Estimated Time:** 25-35 development sessions
**Approach:** Sequential phases with some parallel work opportunities

---

### Phase 1: Database Foundation - Create New Schema
**Status:** Pending
**Estimated Time:** 2-3 sessions
**Priority:** Critical - Foundation for all future work

#### Objectives:
- Create all 6 normalized tables with proper relationships
- Enhance existing students table
- Set up proper indexing and constraints

#### Tasks:

**1. Enhance Students Table Migration**
   - Add missing fields from schema design
   - Ensure tribal_id is unique and indexed
   - Keep existing financial tracking fields (total_undergrad_awarded, total_grad_awarded)
   - Add any missing contact/address fields
   - Migration file: `db/migrate/XXX_enhance_students_table.rb`

**2. Create New Applications Table**
   - Migrate ALL 275+ fields from scholarship_applications
   - **CRITICAL**: Keep field names identical for form compatibility
   - **Add new fields:**
     - `application_key` (string, unique, human-readable: "2025-001", "2025-002")
     - `student_id` (foreign key → students.id) - Links application to person
     - `application_type` (enum: digital, historical_import)
     - Rename existing "student_id" to "school_issued_student_id" to avoid confusion
   - **Note:** school_issued_student_id is just form data (can change between schools/transfers)
   - **Indexes:** application_key, student_id, application_year, status, board_status
   - Migration file: `db/migrate/XXX_create_applications.rb`

**3. Create Student Financial Tracking Table**
   - student_id (foreign key → students.id)
   - application_id (foreign key → applications.id)
   - award_year, award_type (enum: regular, arpa, combined)
   - semester_1_amount, semester_2_amount, total_award_amount
   - award_source (enum: verification_workflow, manual_entry)
   - is_current_application (boolean - for threshold checking)
   - notes (text)
   - **Indexes:** student_id, application_id, award_year
   - Migration file: `db/migrate/XXX_create_student_financial_tracking.rb`

**4. Create Application Files Table**
   - application_id (foreign key → applications.id)
   - student_id (foreign key → students.id - for profile-attached files)
   - file_category (enum: fafsa, transcript_fall, transcript_spring, course_schedule, acceptance_letter, other)
   - file_name, file_description
   - attachment_location (enum: application, student_profile)
   - uploaded_at
   - Active Storage integration
   - **Indexes:** application_id, student_id, file_category
   - Migration file: `db/migrate/XXX_create_application_files.rb`

**5. Create Verification Templates Table**
   - application_id (foreign key → applications.id)
   - template_data (JSON field for verification checklist items)
   - completion_status (enum: not_started, in_progress, completed)
   - verified_by_staff_id (integer - staff member who verified)
   - verification_started_at, verification_completed_at (datetime)
   - notes (text field for staff comments)
   - **Indexes:** application_id, completion_status, verified_by_staff_id
   - Migration file: `db/migrate/XXX_create_verification_templates.rb`

**6. Create Historical Applications Table**
   - student_id (foreign key → students.id)
   - application_year, school_name
   - amount_requested, amount_earned
   - award_type (enum: regular, arpa, combined)
   - entry_date, entered_by_staff_id
   - notes (text)
   - **Indexes:** student_id, application_year
   - Migration file: `db/migrate/XXX_create_historical_applications.rb`

#### Success Criteria:
- All migrations run without errors
- Database schema matches target design
- All indexes created properly
- Old scholarship_applications table remains intact (for now)

---

### Phase 2: Core Models and Data Architecture
**Status:** Pending
**Estimated Time:** 2-3 sessions
**Priority:** Critical - Core business logic

#### Objectives:
- Build all model classes with associations
- Implement validations and business logic
- Set up model callbacks for data integrity

#### Tasks:

**1. Create/Update Models**
   - `app/models/student.rb` (enhance existing)
   - `app/models/application.rb` (new - replaces ScholarshipApplication)
   - `app/models/student_financial_tracking.rb` (new)
   - `app/models/application_file.rb` (new)
   - `app/models/verification_template.rb` (new)
   - `app/models/historical_application.rb` (new)

**2. Define Associations**
   ```ruby
   # Student model
   has_many :applications, dependent: :destroy
   has_many :financial_trackings, class_name: 'StudentFinancialTracking', dependent: :destroy
   has_many :historical_applications, dependent: :destroy
   has_many :application_files, dependent: :destroy

   # Application model
   belongs_to :student
   has_one :verification_template, dependent: :destroy
   has_many :application_files, dependent: :destroy
   has_many :financial_trackings, class_name: 'StudentFinancialTracking', dependent: :destroy

   # VerificationTemplate model
   belongs_to :application

   # StudentFinancialTracking model
   belongs_to :student
   belongs_to :application

   # ApplicationFile model
   belongs_to :application, optional: true
   belongs_to :student, optional: true
   has_one_attached :file
   ```

**3. Implement Validations**
   - tribal_id: presence, uniqueness, format
   - application_key: presence, uniqueness, format (YYYY-NNN)
   - Required fields per model
   - Enum validations for all enum fields
   - Foreign key validations

**4. Add Model Methods**
   - `Application.generate_application_key` (automatic generation)
   - `Student.lifetime_undergrad_total` (calculation method)
   - `Student.lifetime_grad_total` (calculation method)
   - `Student.threshold_warning?` (check if near limits)
   - `Application.current_possible_award` (for unverified applications)
   - `ApplicationFile.categorized_by_type` (grouping helper)
   - `VerificationTemplate.checklist_items` (JSON parsing helper)

#### Success Criteria:
- All models pass validation tests
- Associations work correctly in Rails console
- Can create test records successfully
- Model methods return expected values

---

### Phase 3: Data Migration Strategy
**Status:** Pending
**Estimated Time:** 2-3 sessions
**Priority:** High - Preserve existing data

#### Objectives:
- Migrate existing scholarship_applications data to new structure
- Create student profiles from application data
- Maintain data integrity throughout migration

#### Tasks:

**1. Data Analysis**
   - Count unique students by tribal_id (student_id field in current table)
   - Count total existing applications
   - Identify data quality issues:
     - Missing tribal_ids
     - Duplicate tribal_ids
     - Invalid data formats
   - Create data quality report

**2. Create Migration Script**
   - `lib/tasks/data_migration.rake`
   - Extract unique students from applications (group by tribal_id)
   - Create student records with proper data
   - Migrate applications to new table
   - Generate application_keys (format: YYYY-NNN)
   - Link applications to students via student_id foreign key
   - Handle school_issued_student_id renaming

**3. Handle Edge Cases**
   - Missing tribal_ids: Flag for staff review, create temporary student record
   - Duplicate detection: Merge strategy or manual review
   - Data validation errors: Log and skip, create error report
   - Rollback strategy: Keep script reversible

**4. Verify Migration**
   - Count verification: students created == unique tribal_ids
   - Count verification: applications migrated == original count
   - Relationship verification: all applications linked to students
   - Data integrity checks: spot-check random records
   - Test queries work correctly on new schema

#### Success Criteria:
- All existing data migrated successfully
- Student-application relationships correct
- No data loss
- Error report generated for manual review
- Old table can be safely archived

---

### Phase 4: Student Profile Pages & Historical Import
**Status:** Pending
**Estimated Time:** 3-4 sessions
**Priority:** High - Core staff workflow

#### Objectives:
- Build comprehensive student profile interface
- Create historical data import functionality
- Display lifetime financial tracking

#### Tasks:

**1. Student Profile Controller & Routes**
   ```ruby
   # config/routes.rb
   namespace :admin do
     resources :students do
       resources :applications, only: [:index, :show]
       resources :historical_applications, only: [:new, :create]
     end
   end
   ```
   - Index page: student list with search/filter
   - Show page: comprehensive student profile
   - Create/edit: for manual profile creation
   - Nested routes for applications

**2. Student Profile Views**
   - `app/views/admin/students/index.html.erb` - Student list
   - `app/views/admin/students/show.html.erb` - Profile page with:
     - Student information display
     - Lifetime financial summary table
     - Applications list (current + historical)
     - Application detail preview cards
     - File attachments list (from all applications)
     - Verification history timeline
   - `app/views/admin/students/_form.html.erb` - Student edit form

**3. Historical Import Interface**
   - `app/views/admin/historical_applications/new.html.erb`
   - Simple form on student profile page
   - Two workflows:
     - Create new student + import historical data
     - Add historical applications to existing student
   - Required fields: name, year, tribal_id, school, amount_requested, amount_earned
   - Validation and error handling
   - Success/failure messages

**4. Financial Tracking Display**
   - Undergraduate total awarded (lifetime)
   - Graduate total awarded (lifetime)
   - Current application "possible amount" (not yet added to total)
   - Threshold warning indicators (close_to_limit flags)
   - Award history by year table
   - Semester breakdown display

#### Success Criteria:
- Staff can view complete student history
- Historical import creates records correctly
- Financial tracking displays accurately
- Threshold warnings appear appropriately
- UI is intuitive for staff use

---

### Phase 5: Rebuild Core Application Functionality
**Status:** Pending
**Estimated Time:** 4-5 sessions
**Priority:** High - Essential features

#### Objectives:
- Rebuild application submission form
- Rebuild admin review interface
- Update all controllers for new schema
- Ensure student-facing experience works

#### Tasks:

**1. Application Submission Form**
   - Update `app/controllers/scholarship_applications_controller.rb`
   - Form submission workflow:
     - Find or create student by tribal_id
     - Create application record linked to student
     - Generate application_key automatically
     - Keep all field names identical (form compatibility)
     - Handle file uploads properly
   - Error handling and validation messages
   - Success confirmation with application_key display

**2. Admin Application Review**
   - Update `app/controllers/admin/scholarship_applications_controller.rb`
   - Rename to `app/controllers/admin/applications_controller.rb`
   - Index page: applications list with student info, search, filter
   - Show page: full application display with:
     - Student information section
     - Application details (all form fields)
     - File attachments
     - Verification status
     - Award information
   - Edit functionality with new schema
   - Status management (approve, deny, request_info)
   - Board status tracking

**3. Dashboard Updates**
   - Update `app/controllers/admin/dashboard_controller.rb`
   - Statistics: total applications, by status, by year
   - Current applications overview table
   - Status breakdown charts/summaries
   - Quick actions (recent applications, pending reviews)

**4. Application Status Checking**
   - Student-facing status lookup page
   - Search by tribal_id or application_key
   - Display application progress and verification status
   - Show award amounts (if verified)
   - Next steps messaging

#### Success Criteria:
- Students can submit applications successfully
- Applications link to student profiles correctly
- Staff can review and update applications
- All status management works
- Dashboard displays accurate statistics
- Status lookup functions properly

---

### Phase 6: File Management System
**Status:** Pending
**Estimated Time:** 2-3 sessions
**Priority:** Medium-High - Important feature
**Can run parallel with Phase 5**

#### Objectives:
- Implement categorized file uploads
- Support dual attachment (application + profile)
- Staff file management capabilities

#### Tasks:

**1. File Upload Interface**
   - Update application form with categorized upload sections:
     - FAFSA upload
     - Transcript - Fall semester
     - Transcript - Spring semester
     - Course schedule
     - Acceptance letter
     - Other documents
   - Semester-specific transcript uploads
   - Upload to application or student profile option
   - File preview and validation (size, format)
   - Progress indicators

**2. Admin File Management**
   - View files by category in admin interface
   - Download/view capabilities (inline preview)
   - Remove duplicate files (staff action)
   - File status indicators (✓ present / ✗ missing)
   - Required file checklist per application

**3. Student Profile File Display**
   - Organized file list on student profile:
     - Application-linked files (grouped by application)
     - Profile-specific files
   - Organize by category and semester
   - Quick download/view access
   - Visual indicators for file types

**4. File Tracking**
   - Track upload dates and timestamps
   - Track uploader (if logged in admin)
   - Required file validation
   - Missing file alerts on verification template
   - File count summaries

#### Success Criteria:
- File uploads work for all categories
- Files properly categorized and stored
- Staff can manage files easily (view, download, delete)
- Student profile shows all relevant files organized clearly
- Required file tracking works

---

### Phase 7: Verification Workflow System
**Status:** Pending
**Estimated Time:** 4-5 sessions
**Priority:** High - Core staff workflow

#### Objectives:
- Build web-based verification interface
- Implement verification template system
- Auto-save functionality
- Support bulk and individual processing

#### Tasks:

**1. Verification Template Design**
   - Define verification checklist items:
     - Tribal ID verified
     - Transcripts received and reviewed
     - FAFSA reviewed
     - Enrollment verified
     - GPA requirements met
     - Course load verified
     - FNA calculated and reviewed
     - Recommendation for award amount
   - JSON structure for template_data
   - Configurable checklist items
   - Status tracking per item (pending/complete)

**2. Bulk Verification Interface**
   - `app/views/admin/verifications/index.html.erb`
   - Page showing ALL current applications in table format
   - Inline verification checkboxes for each item
   - Work through applications sequentially
   - Auto-save progress (AJAX updates)
   - Completion status indicators
   - Filter by status (not_started, in_progress, completed)
   - Pagination for large datasets

**3. Individual Application Verification**
   - `app/views/admin/verifications/show.html.erb`
   - Detailed verification view for single application
   - Complete checklist with descriptions
   - Staff notes section
   - Award amount entry fields:
     - amount_awarded (regular scholarship)
     - arpa_amount_awarded (ARPA funding)
     - Semester 1 amount
     - Semester 2 amount
   - Award entry triggers financial tracking update
   - Verification completion workflow
   - Mark as complete button

**4. Verification History**
   - Student profile shows all verification templates
   - Historical verification review (read-only for past)
   - Current verification (editable)
   - Audit trail display:
     - Who verified
     - When verified
     - What was verified
   - Verification status timeline

**5. Financial Integration**
   - Award amounts from verification auto-populate StudentFinancialTracking
   - Automatic semester breakdown
   - Current vs confirmed distinction
   - Threshold checking triggers warnings
   - Update student.total_undergrad_awarded or total_grad_awarded upon completion

#### Success Criteria:
- Staff can verify applications efficiently
- Bulk workflow allows quick processing
- Individual workflow supports detailed review
- Progress auto-saves reliably
- Financial tracking updates correctly when awards entered
- Verification history maintained and viewable
- Threshold warnings appear when appropriate

---

### Phase 8: CSV Export & Reporting System
**Status:** Pending
**Estimated Time:** 2-3 sessions
**Priority:** Medium - Useful feature

#### Objectives:
- Fix broken CSV export
- Implement multiple export formats
- Support verification template exports

#### Tasks:

**1. Create Export Services**
   - `app/services/application_export_service.rb`
   - `app/services/verification_export_service.rb`
   - `app/services/student_export_service.rb`
   - Proper field mapping
   - Human-readable headers
   - Nested data handling (FNA breakdown, etc.)

**2. Export Options Implementation**
   - **Single application export:** All data for one application
   - **Bulk application export:** All current cycle applications
   - **Student bulk export:** All applications for one student (current + historical)
   - **Verification template exports:**
     - Single application verification
     - Student verification history
     - Bulk current verifications
   - **Custom field selection:** (future enhancement)

**3. Admin Export Interface**
   - Export buttons on appropriate pages:
     - Application show page: "Export This Application"
     - Student profile: "Export Student History"
     - Applications index: "Export All Current"
     - Verifications index: "Export Verification Templates"
   - Format selection dropdown (CSV, future: PDF)
   - Date range filtering
   - Status filtering (submitted, verified, approved, etc.)
   - Download triggers

**4. Export Formatting**
   - Clean, descriptive column headers
   - Proper data formatting (dates, currency, booleans)
   - Include related data (student info with applications)
   - Nested data handling (expand FNA fields into columns)
   - UTF-8 encoding support
   - Excel-compatible formatting

#### Success Criteria:
- CSV exports generate correctly
- All export formats work as specified
- Data is properly formatted and readable in Excel
- Staff can easily export needed data
- Export performance acceptable for large datasets

---

### Phase 9: Testing & Quality Assurance
**Status:** Ongoing throughout all phases
**Estimated Time:** 2-3 sessions dedicated testing
**Priority:** Medium - Ensure stability

#### Objectives:
- Comprehensive test coverage
- Bug fixing
- Performance optimization

#### Tasks:

**1. Model Tests**
   - Validation tests for all models
   - Association tests (has_many, belongs_to)
   - Method tests (calculations, generators)
   - Edge case handling
   - Test file: `test/models/*_test.rb`

**2. Controller Tests**
   - Request specs for all actions (index, show, create, update, destroy)
   - Authorization checks (admin vs public)
   - Parameter handling and strong params
   - Error conditions and edge cases
   - Test file: `test/controllers/*_test.rb`

**3. Integration Tests**
   - Complete application submission flow
   - Student profile creation and update flow
   - Verification workflow end-to-end
   - File upload process
   - CSV export generation
   - Test file: `test/integration/*_test.rb`

**4. System Tests**
   - User interface testing with Capybara
   - JavaScript interactions (auto-save, AJAX)
   - Form submissions with validation
   - File uploads with different formats
   - Navigation flows
   - Test file: `test/system/*_test.rb`

**5. Performance Testing**
   - Query optimization (use `includes`, `joins`)
   - N+1 query prevention (Bullet gem)
   - Index verification (check EXPLAIN plans)
   - Large dataset handling (pagination)
   - Load testing with sample data

#### Success Criteria:
- Test coverage > 80%
- No critical bugs
- Performance acceptable for 1000+ applications
- All workflows tested end-to-end
- No N+1 queries in main flows

---

### Phase 10: Documentation & Deployment Preparation
**Status:** Pending
**Estimated Time:** 1-2 sessions
**Priority:** Low-Medium - Important for maintenance

#### Objectives:
- Document new system
- Prepare for deployment
- Clean up old code

#### Tasks:

**1. Code Documentation**
   - Model comments for complex logic
   - Method documentation (YARD format)
   - Database schema documentation (schema_comments gem)
   - README updates with new structure
   - ERD diagram generation

**2. User Documentation**
   - Staff user guide (how to use verification system)
   - Admin workflow documentation
   - Student application guide
   - Troubleshooting guide (common issues)
   - FAQ document

**3. Clean Up**
   - Remove old scholarship_applications table (final migration)
   - Remove unused code and comments
   - Remove old views/partials no longer used
   - Clean up routes file
   - Remove deprecated methods

**4. Deployment Preparation**
   - Environment configuration check
   - Database backup procedures documented
   - Migration plan for production
   - Rollback procedures documented
   - Performance monitoring setup

#### Success Criteria:
- System fully documented
- Old code removed safely
- Ready for production deployment
- Staff training materials prepared
- Rollback plan tested

---

## Phase Dependencies & Timeline

**Phase Order (with dependencies):**
1. ✅ **Phase 1** (Database) → Must complete first
2. ✅ **Phase 2** (Models) → Depends on Phase 1
3. ✅ **Phase 3** (Migration) → Depends on Phases 1-2
4. **Phase 4** (Profiles) → Depends on Phases 1-3
5. **Phase 5** (Core Features) → Depends on Phases 1-4
6. **Phase 6** (Files) → Can parallel with Phase 5
7. **Phase 7** (Verification) → Depends on Phase 5
8. **Phase 8** (Exports) → Depends on Phase 7
9. **Phase 9** (Testing) → Throughout all phases
10. **Phase 10** (Documentation) → Final phase

**Parallel Work Opportunities:**
- Phase 6 (Files) can run parallel with Phase 5 (Core Features)
- Phase 9 (Testing) should happen throughout development
- Documentation can be written as features are completed

---

## Risk Mitigation

**High-Risk Areas:**
1. **Data Migration (Phase 3)** - Risk: Data loss or corruption
2. **Verification Workflow (Phase 7)** - Risk: Complex logic, calculation errors
3. **Financial Tracking (Phases 4, 7)** - Risk: Incorrect award calculations, threshold errors

**Mitigation Strategies:**
- Comprehensive testing at each phase
- Frequent progress reports and demos
- Can break functionality temporarily (not deployed, development freedom)
- Keep old scholarship_applications table as backup until fully confident
- Test with realistic sample data
- Manual QA testing of critical workflows
- Rollback procedures documented

---

## Key Field Clarifications

**CRITICAL - Student ID Disambiguation:**
- **tribal_id:** Permanent person identifier (like SSN), unique, never changes - PRIMARY KEY FOR PERSON
- **students.id:** Database primary key (auto-increment)
- **applications.student_id:** Foreign key pointing to students.id (links application to person)
- **applications.school_issued_student_id:** School's student ID number (form data, can change between schools)

**Application Identifiers:**
- **applications.id:** Database primary key
- **applications.application_key:** Human-readable unique ID (YYYY-NNN format) for staff reference

---

This comprehensive plan provides a realistic roadmap for the complete database normalization and application rebuild with clear phases, dependencies, and success criteria.

---

## Authentication & Authorization Requirements

### System Role Architecture

**Three-Tier Role System:**
The application requires three distinct role levels with standardized permissions within each tier. Each account represents a different person, and there is no hierarchy within role levels - all accounts in a role have identical permissions.

#### 1. Admin Role (3-4 Accounts)
**Full System Access:**
- Complete application management (create, read, update, delete)
- Student profile management (create, read, update, delete)
- Account management (create, modify, delete user accounts)
- System configuration and settings
- All verification workflow capabilities
- All reporting and export capabilities
- Historical application import and management
- Financial tracking management
- Board decision oversight

**Key Distinguishing Capabilities:**
- Can create/modify/delete other user accounts (including other admins, staff, and board members)
- Can modify system-wide settings and configurations
- Can override or modify board decisions if needed
- Full audit log access

#### 2. Staff Role (4 Accounts)
**Full Application & Verification Management:**
- Complete application management (create, read, update, delete)
- Student profile management (create, read, update, delete)
- Full verification workflow access (all stages)
- Award amount entry and modification
- Historical application import and management
- Financial tracking updates
- File management (upload, view, download, delete)
- All reporting and export capabilities
- View board member feedback and votes

**Key Distinguishing Capabilities:**
- Primary verification workflow operators
- Award amount determination and entry
- Historical data import interface access
- Student profile creation and maintenance
- Cannot create/modify/delete user accounts
- Cannot modify system settings

**Restrictions:**
- No account management capabilities
- No system configuration access
- Read-only view of board decisions (cannot modify)

#### 3. Board Member Role (8-10 Accounts)
**Limited Review Portal:**
- Read-only access to applications assigned for review
- View student profiles (read-only)
- View financial summaries and award histories
- Submit votes on applications (approve/deny/abstain)
- Submit feedback/comments with votes (visible to staff)
- View application documents and files (read-only)
- View verification status (read-only)

**Key Distinguishing Capabilities:**
- Voting capability on applications
- Feedback/comment submission with votes
- Application review workflow

**Restrictions:**
- Cannot modify applications or student data
- Cannot upload or delete files
- Cannot create or modify user accounts
- Cannot access verification workflow (staff-only)
- No export capabilities
- Cannot see other board members' votes or feedback (staff-only visibility)
- No system configuration access

### Authentication Requirements

**Account Management:**
- Admins create all user accounts (admin, staff, board member)
- Each account tied to specific individual (no shared accounts)
- Email-based authentication with secure passwords
- Password reset capability
- Session management with automatic logout after inactivity
- Optional: Multi-factor authentication (future enhancement)

**Role Assignment:**
- Single role per account (no mixed roles)
- Role changes require admin action
- Role change audit trail

### Database Schema for Authentication

```ruby
users (new table for authentication system)
  - id (primary key)
  - email (unique, required)
  - encrypted_password
  - role (enum: admin, staff, board_member)
  - first_name, last_name
  - active (boolean - can be deactivated without deletion)
  - last_login_at
  - created_at, updated_at
  - created_by_admin_id (foreign key -> users.id, tracks who created account)

# Extension of existing tables to track actions
verification_templates
  - verified_by_staff_id (foreign key -> users.id where role = staff)

historical_applications
  - entered_by_staff_id (foreign key -> users.id where role = staff)

board_votes (new table for board member decisions)
  - id (primary key)
  - application_id (foreign key -> applications.id)
  - board_member_id (foreign key -> users.id where role = board_member)
  - vote (enum: approve, deny, abstain)
  - feedback (text - comments visible to staff)
  - voted_at
  - created_at, updated_at
```

### Authorization Implementation Strategy

**Controller-Level Checks:**
- `before_action :authenticate_user!` - Require login for all admin/staff/board routes
- `before_action :authorize_admin!` - Admin-only actions (account management, settings)
- `before_action :authorize_staff_or_admin!` - Staff and admin actions (verification workflow)
- `before_action :authorize_board_member!` - Board member review portal

**View-Level Permissions:**
- Conditional rendering based on current_user.role
- Hide/show action buttons based on permissions
- Display appropriate navigation based on role

**Model-Level Validations:**
- Ensure only authorized roles can create/modify records
- Track who made changes (created_by, updated_by fields)
- Audit trail for sensitive operations

### Implementation Priority

**Phase Priority:** Should be implemented early (suggest after Phase 3 - Data Migration)
- Required before verification workflow (Phase 7)
- Needed for proper audit trail in student profiles (Phase 4)
- Board member portal can be added separately after core features

**Phased Authentication Implementation:**
1. **Basic Authentication** - User model, sessions, login/logout (Phase 4)
2. **Admin & Staff Roles** - Differentiate permissions for core workflow (Phase 4-5)
3. **Board Member Portal** - Limited review interface with voting (Phase 7 or later)
4. **Enhanced Security** - Multi-factor auth, session timeout, password policies (Future)

---

## Application Lifecycle & Deadline Management

### Core Lifecycle Concept

**10-Month Application Lifecycle:**
- All applications for a given period (year/semester/quarter) start their lifecycle on the **application deadline date**, not submission date
- Early submissions are immediately visible to staff but show extended time remaining
- Example: If deadline is September 1 and student submits August 21:
  - Staff sees application immediately (submitted status)
  - Lifecycle timer shows "10 months, 10 days" (10 months from deadline + 10 days early)
  - Countdown starts September 1 and runs for 10 months

**Visual Representation:**
```
Student submits early (August 21)
    ↓
Application visible immediately (status: submitted)
    ↓
Deadline passes (September 1) ← LIFECYCLE START
    ↓
10-month countdown begins
    ↓
Staff verification and board review (months 1-6)
    ↓
Award disbursement tracking (throughout)
    ↓
Transcript submission deadline (after semester 1)
    ↓
Second semester payment processing
    ↓
10 months expire (July 1) → Auto-archive OR Manual finalization
```

### Archiving Methods

**Two Ways Applications Are Archived:**

#### 1. Automatic Archiving (Time-Based)
- **Trigger:** 10 months after application deadline date
- **Condition:** Application not manually finalized by staff
- **Status Change:** Moves to "archived" status automatically
- **Visibility:** Moves to historical view, no longer in "current applications" list
- **Use Case:** Applications that fell through the cracks, incomplete submissions, withdrawn applications

#### 2. Manual Finalization (Primary Method)
- **Trigger:** Staff action marking application as complete
- **Required Action:** Staff explicitly marks as one of:
  - "Finalized and Paid" - Award fully disbursed, all requirements met
  - "Finalized and Denied" - Application denied by board, process complete
- **Timing:** Can happen any time during 10-month window
- **Effect:** Immediately moves to archived status even if 10 months not elapsed
- **Use Case:** Normal completion of application process

**Best Practice:**
- Staff should manually finalize all applications once process complete
- Automatic archiving acts as safety net for forgotten applications
- Historical applications remain accessible in student profiles indefinitely

### Deadline Tracking System

**Two Critical Deadlines Per Application:**

#### 1. Initial Application Submission Deadline
- **Purpose:** Determines which application cycle submission belongs to
- **Configuration:** Set by admin for each period (e.g., "Fall 2025 deadline: September 1, 2025")
- **Effect on Students:**
  - Clear submission deadline communicated on application form
  - Late submissions go to next cycle or require admin override
- **Effect on Lifecycle:** This is the date that starts the 10-month countdown

#### 2. Transcript Submission Deadline (Semester-Specific)
- **Purpose:** Ensures students submit proof of successful first semester before second semester payment
- **Timing:** After first semester ends (e.g., "Fall transcripts due by January 15")
- **Configuration:** Set per semester/quarter within verification workflow
- **Effect:**
  - Second semester payment withheld until transcript received
  - Staff can mark transcript requirement as satisfied
  - Verification template tracks transcript submission status
- **Use Case:** Student receives $3,000 for fall semester, must submit fall transcript by January 15 to receive spring semester payment

### Database Schema for Lifecycle Management

```ruby
application_cycles (new table - configuration for deadlines)
  - id (primary key)
  - cycle_name (e.g., "Fall 2025", "Academic Year 2025-2026")
  - application_deadline (date - when submissions close)
  - cycle_start_date (date - when lifecycle countdown begins, usually same as deadline)
  - cycle_type (enum: yearly, semester, quarter)
  - transcript_deadline_semester_1 (date - optional, for semester-based)
  - transcript_deadline_semester_2 (date - optional, for semester-based)
  - active (boolean - current cycle)
  - created_at, updated_at

applications (add lifecycle fields)
  - application_cycle_id (foreign key -> application_cycles.id)
  - submitted_at (datetime - when student actually submitted)
  - lifecycle_start_date (date - pulled from application_cycle.cycle_start_date)
  - lifecycle_end_date (date - calculated: lifecycle_start_date + 10 months)
  - finalized_at (datetime - when staff marked as complete)
  - finalization_status (enum: finalized_paid, finalized_denied, auto_archived, null)
  - archived (boolean - whether moved to historical view)
  - transcript_1_received (boolean)
  - transcript_1_received_at (datetime)
  - transcript_2_received (boolean)
  - transcript_2_received_at (datetime)
```

### Lifecycle Display Logic

**Staff Dashboard View:**
```
Application #2025-042
Submitted: August 21, 2025 (10 days before deadline)
Lifecycle: 10 months, 10 days remaining
Status: Under Review
Deadline: September 1, 2025
Archive Date: July 1, 2026
Finalization: Not finalized
```

**Calculation:**
```ruby
# Pseudo-code for lifecycle display
days_before_deadline = (application_cycle.application_deadline - application.submitted_at).days
lifecycle_days_remaining = (application.lifecycle_end_date - Date.today).days
total_days_remaining = lifecycle_days_remaining + days_before_deadline

display = "#{lifecycle_days_remaining / 30} months, #{lifecycle_days_remaining % 30} days"
```

### Future Enhancement: Flexible Cycle Editing

**Known Limitation:**
Current system assumes standard academic calendar (Fall/Spring or yearly)

**Future Need:**
Some students take summer or winter courses requiring application cycle adjustments

**Planned Solution:**
- Admin interface to manually adjust lifecycle_start_date and lifecycle_end_date per application
- Override capability for non-standard academic schedules
- Audit trail for lifecycle modifications

**Implementation Priority:** Low - Handle edge cases manually until pattern emerges

---

## Award Threshold Configuration & Warning System

### Award Limits by Education Level

**Configurable Thresholds (Not Hardcoded):**

#### Undergraduate Limit
- **Default Amount:** $15,000 lifetime limit
- **Scope:** All undergraduate programs (Associate's, Bachelor's degrees)
- **Configuration:** Admin-editable in system settings
- **Tracking Field:** `students.total_undergrad_awarded`

#### Graduate Limit
- **Default Amount:** $9,000 lifetime limit
- **Scope:** All graduate programs (Master's, PhD, professional degrees)
- **Configuration:** Admin-editable in system settings
- **Tracking Field:** `students.total_grad_awarded`

**Important Principle:**
- Limits are **informational, not enforcement**
- Final award decisions made by staff/board regardless of limits
- System provides warnings and context, not hard blocks

### Warning System Logic

**Threshold Warning Flags:**
```ruby
students
  - close_to_undergrad_limit (boolean)
  - close_to_grad_limit (boolean)
  - last_threshold_check_at (datetime)
```

**Warning Trigger Points:**
- **Yellow Warning:** Student has received 80% or more of limit ($12,000+ for undergrad, $7,200+ for grad)
- **Red Warning:** Current application + lifetime total would exceed limit
- **Information Display:** Always show current totals and requested amount

**Visual Representation in Staff Interface:**
```
Student: Jane Doe (Tribal ID: 12345)
Undergraduate Lifetime Awards: $13,500 / $15,000 limit
⚠️ WARNING: Close to undergraduate limit ($1,500 remaining)

Current Application Request: $3,000
❌ ALERT: This application would exceed limit by $1,500

Graduate Lifetime Awards: $0 / $9,000 limit
✓ No concerns

Board Decision: Approve anyway | Deny | Adjust award amount
```

### Award Calculation & Tracking

**Three Financial States:**

#### 1. Current Application (Unverified)
- **Status:** Application submitted but not yet verified/approved
- **Amount:** `applications.amount_requested` + `applications.arpa_amount_requested`
- **Display:** Shows as "Possible Award" in student profile
- **Effect on Totals:** **NOT included** in lifetime totals until finalized

#### 2. Verified Application (Approved, Not Yet Disbursed)
- **Status:** Verification complete, board approved, award determined
- **Amount:** `applications.amount_awarded` + `applications.arpa_amount_awarded`
- **Effect on Totals:** **Included** in lifetime totals immediately upon verification completion
- **Tracking:** Creates record in `student_financial_tracking` table
- **Update:** Automatically increments `students.total_undergrad_awarded` or `students.total_grad_awarded`

#### 3. Disbursed Award (Payment Made)
- **Status:** Funds transferred to student or institution
- **Amount:** Tracked in `student_financial_tracking` with semester breakdown
- **Effect:** Already in lifetime totals, now marked as disbursed
- **Tracking:** `semester_1_amount`, `semester_2_amount` fields updated as payments made

### Threshold Checking Workflow

**When Threshold Checks Occur:**
1. **Application Submission:** Check if student is close to limits, display warning
2. **Verification Workflow:** Staff sees threshold warnings during review
3. **Award Entry:** Real-time calculation showing impact on lifetime totals
4. **Board Review:** Board members see threshold context when voting
5. **Student Profile View:** Always displays current totals and warnings

**Calculation Logic:**
```ruby
# Pseudo-code for threshold checking
current_undergrad_total = student.total_undergrad_awarded
requested_amount = application.amount_requested
undergrad_limit = SystemSetting.undergrad_limit # $15,000 default

# Check if close to limit (80% threshold)
if current_undergrad_total >= (undergrad_limit * 0.8)
  student.update(close_to_undergrad_limit: true)
end

# Check if current application would exceed
if (current_undergrad_total + requested_amount) > undergrad_limit
  warning = "This application would exceed limit by $#{(current_undergrad_total + requested_amount) - undergrad_limit}"
end
```

### Carryover Between Undergraduate and Graduate

**Current Status:** Pending Email Clarification
- **Question:** Do unused undergraduate funds carry over to graduate limit?
  - Example: Student used $10,000 undergrad, has $5,000 unused. Can they access full $9,000 grad limit or only $4,000?
- **Options:**
  - **Separate Pools:** Undergrad and grad limits are completely independent
  - **Combined Lifetime:** Single $24,000 lifetime limit with sub-limits per level
  - **Conditional Carryover:** Unused undergrad funds can apply to grad, but not vice versa

**Implementation Plan:**
- Initially implement as **separate pools** (simpler, most common model)
- Database structure supports easy change to combined model if needed
- Admin configuration allows switching between models without code changes

**Database Configuration:**
```ruby
system_settings (new table for configurable limits)
  - id (primary key)
  - setting_key (unique)
  - setting_value (json)
  - description
  - updated_by_admin_id
  - created_at, updated_at

# Example records:
{setting_key: 'undergrad_limit', setting_value: 15000, description: 'Undergraduate lifetime award limit'}
{setting_key: 'grad_limit', setting_value: 9000, description: 'Graduate lifetime award limit'}
{setting_key: 'limit_model', setting_value: 'separate', description: 'separate | combined | carryover'}
```

### Staff Override Capability

**Important Principle:**
Award limits are guidelines, not absolute rules. Staff and board can approve awards exceeding limits when justified.

**Override Workflow:**
1. System displays warning when limit would be exceeded
2. Staff/board see clear notification with context
3. Decision makers can:
   - Approve full requested amount (override limit)
   - Approve partial amount (stay within limit)
   - Deny application citing limit as reason
4. Override is recorded in notes field
5. Audit trail captures override decision and justification

**Database Tracking:**
```ruby
applications (add override fields)
  - threshold_override (boolean - true if approved despite exceeding limit)
  - override_justification (text - why limit was exceeded)
  - override_approved_by_staff_id (foreign key -> users.id)
  - override_approved_at (datetime)
```

### Integration with Verification Workflow

**Threshold Display in Verification Interface:**
- Automatic calculation during award amount entry
- Real-time feedback: "Entering $3,000 will bring student to $13,500 / $15,000 (90% of limit)"
- Warning badges on applications near/over limits
- Filterable view: "Show applications near threshold"

**Board Member View:**
- Simplified threshold display for context
- Current totals and requested amounts clearly shown
- Warnings displayed without technical details
- Board feedback can reference threshold concerns

### Reporting & Analytics

**Threshold Reports (Future Enhancement):**
- Students approaching limits (proactive outreach)
- Historical trend analysis (are limits appropriate?)
- Override frequency tracking (how often do we exceed limits?)
- Award distribution by education level

**Implementation Priority:** Basic threshold checking in Phase 7 (Verification Workflow), advanced reporting in Phase 8+ or future enhancements

---

## Board Member Portal Specifications

### Core Functionality

**Board Member Capabilities:**
1. **View Applications Assigned for Review**
   - Read-only access to complete application details
   - Student profile view (historical context)
   - Verification status visibility
   - Financial needs analysis review
   - Uploaded documents access (view/download only)

2. **Submit Votes on Applications**
   - Three vote options: Approve, Deny, Abstain
   - Cannot change vote after submission (or with time limit)
   - One vote per application per board member
   - Vote timestamp recorded

3. **Provide Feedback with Votes**
   - Text field for comments/reasoning
   - Feedback visible to staff only (not other board members)
   - Optional but encouraged for Deny votes
   - Character limit: 1000 characters (configurable)

### Board Voting Workflow

**Application Assignment:**
- All board members see all applications by default (open access model)
- Alternative: Applications assigned to specific board members (future enhancement)
- Applications appear in "Pending Review" queue until board member votes

**Voting Interface:**
```
Application #2025-042 - Jane Doe
Requested Amount: $3,000 (Regular) + $2,000 (ARPA)

[Application details display...]
[Student history display...]
[Financial needs analysis...]

Your Vote:
( ) Approve
( ) Deny
( ) Abstain

Feedback/Comments (visible to staff only):
[Text area: Please provide rationale for your decision, especially if denying...]

[Submit Vote] [Save as Draft]
```

**Vote Submission:**
- Vote immediately recorded in database
- Timestamp captured
- Board member moved to "Reviewed" queue
- Cannot vote twice (or can change vote before deadline - TBD)
- Staff notified when all board members have voted (optional)

### Staff View of Board Votes

**Aggregated Vote Display:**
```
Application #2025-042 - Board Voting Results

Total Votes: 8/10 board members
Approve: 5 votes
Deny: 2 votes
Abstain: 1 vote
Pending: 2 members have not voted yet

Board Member Feedback:
---
Board Member #1 (Approved): "Strong academic record and clear financial need."
Board Member #2 (Approved): "Excellent candidate, recommend full award."
Board Member #3 (Denied): "GPA below threshold, recommend denial or reduced amount."
Board Member #4 (Denied): "Already received significant funding in previous years."
Board Member #5 (Abstain): "Conflict of interest - family member."
---

Staff Action Required: Finalize decision based on board recommendation
```

**Staff Capabilities:**
- View all votes and feedback in one interface
- Export voting results for records
- Filter applications by vote outcome (majority approve, majority deny, split decision)
- Make final decision (can differ from board recommendation)
- Record final decision with justification if overriding board

### Database Schema for Board Voting

```ruby
board_votes (comprehensive)
  - id (primary key)
  - application_id (foreign key -> applications.id)
  - board_member_id (foreign key -> users.id where role = board_member)
  - vote (enum: approve, deny, abstain)
  - feedback (text - comments visible to staff)
  - vote_draft (boolean - true until final submission)
  - voted_at (datetime - when vote finalized)
  - created_at, updated_at

# Indexes for performance
- Index on application_id (fast lookup of all votes for an application)
- Index on board_member_id (fast lookup of all votes by a board member)
- Compound index on (application_id, board_member_id) to ensure one vote per board member per application

# Constraints
- Unique constraint: (application_id, board_member_id) - prevent duplicate voting
- Check constraint: board_member_id must reference user with role = 'board_member'
```

### Board Member Dashboard

**Landing Page After Login:**
```
Board Member Dashboard - Welcome, John Smith

Applications Pending Your Review: 12
Applications You've Reviewed: 45
Current Voting Cycle: Fall 2025

Pending Applications:
[Table with columns: App #, Student Name, Requested Amount, Submitted Date, Action]
#2025-042 | Jane Doe | $5,000 | Aug 21, 2025 | [Review & Vote]
#2025-043 | John Smith | $3,500 | Aug 22, 2025 | [Review & Vote]
...

Completed Reviews:
[Show recent 5-10 with vote outcome]
```

**Navigation:**
- Pending Reviews (default view)
- Completed Reviews (historical record)
- My Profile (contact info, preferences)
- Help/Instructions

### Voting Period Management

**Time-Based Voting Cycles:**
- Admin sets voting period for application cycle
- Example: "Board voting opens October 1, closes October 15"
- Board members cannot vote before period opens
- Late votes possible with admin override (configurable)

**Vote Modification Rules:**
- **Before Deadline:** Board member can change vote any time
- **After Deadline:** Votes locked, no changes allowed
- **Staff Override:** Admin can unlock vote for correction (audit trail)

**Database Fields:**
```ruby
application_cycles (extend previous schema)
  - board_voting_start_date (date)
  - board_voting_end_date (date)
  - voting_period_active (boolean)

board_votes (add lock field)
  - locked (boolean - true after voting period ends)
  - modified_count (integer - track how many times vote changed)
  - last_modified_at (datetime)
```

### Privacy & Confidentiality

**Board Member Isolation:**
- Board members **cannot see** other board members' votes or feedback
- Only staff and admins see aggregated voting results
- Board member sees only their own voting history

**Staff Visibility:**
- Staff see all votes and feedback immediately upon submission
- Real-time vote count updates
- Individual board member identity visible to staff (for follow-up if needed)

**Export & Records:**
- Vote results exported for board meeting minutes (anonymized or attributed as policy dictates)
- Historical vote records maintained indefinitely
- Audit trail for any vote modifications

### Email Notifications (Future Enhancement)

**Board Member Notifications:**
- New applications assigned for review
- Voting period opening/closing reminders
- Vote confirmation upon submission

**Staff Notifications:**
- All board members have voted (voting complete)
- Board member submitted feedback requiring attention
- Split decision requiring staff review

**Implementation Priority:** Phase 7 or later (after core authentication and workflow)

### Mobile Considerations

**Responsive Design Requirements:**
- Board members may review applications on tablets/phones
- Voting interface must be mobile-friendly
- Document viewing should work on mobile devices
- Touch-friendly buttons and navigation

**Future Enhancement:** Native mobile app or progressive web app (PWA) for better mobile experience

### Integration with Verification Workflow

**Workflow Sequence:**
1. Student submits application
2. Staff performs initial verification (completeness, eligibility)
3. Application marked "Ready for Board Review"
4. Board members receive notification
5. Board members vote during voting period
6. Staff reviews board feedback and votes
7. Staff makes final award decision
8. Award entered in verification workflow
9. Financial tracking updated
10. Student notified of decision

**Status Field Updates:**
```ruby
applications
  - status (enum: submitted, under_staff_review, ready_for_board, board_voting_open,
             board_voting_complete, staff_final_decision, awarded, denied)
```

### Implementation Priority

**Board Member Portal Phases:**
1. **Phase 1 (High Priority):** Basic voting capability after staff verification workflow complete
2. **Phase 2 (Medium Priority):** Enhanced feedback system and voting analytics
3. **Phase 3 (Future):** Advanced features (mobile app, vote draft saving, notification system)

**Dependencies:**
- Requires authentication system (Phase 4)
- Requires application review interface (Phase 5)
- Should integrate with verification workflow (Phase 7)

**Suggested Implementation:** Phase 7 or separate Phase 7.5 before CSV exports

---

## Financial Needs Analysis (FNA) & Email Automation System

### Overview: Budget Forecast vs Financial Needs Analysis

**Two Separate Financial Data Systems:**

#### 1. Budget Forecast (Student-Entered Estimate)
- **Who Fills It:** Student during application submission
- **Purpose:** Student's self-reported financial estimate
- **Location:** Section of application form (existing fields in applications table)
- **Visibility:** Staff can view on application page alongside official FNA
- **Status:** Optional or informational data

#### 2. Financial Needs Analysis (FNA) - School-Verified Official Data
- **Who Fills It:** School's financial aid office ONLY
- **Purpose:** Official verification of student's financial need
- **Trigger:** Automatic email sent to school immediately after student submits application
- **Requirement:** Required for application processing
- **Visibility:** Staff can view both Budget Forecast (student estimate) and FNA (official) side-by-side
- **Display:** Totals from both may appear on verification workflow page for comparison

---

### FNA Request System - School Verification Workflow

#### Automatic FNA Request Process

**Trigger Event:** Student submits application

**Automated Actions:**
1. **Email to School's Financial Aid Office** (automatic, business hours only)
   - Sent from: `scholarships@sitkatribe-nsn.gov`
   - Timing: Business hours only (8am-5pm Alaska Time, Monday-Friday)
   - Late submissions: Queue for next business morning
   - Content includes:
     - Student identification (full name, DOB, school-issued student ID)
     - Clear explanation of scholarship application from Sitka Tribe of Alaska
     - Secure upload link OR PDF option
     - Contact information for verification

2. **Email to Student** (automatic, immediate)
   - Confirmation that application received
   - Notification that school has been contacted for FNA
   - Request to inform school to expect email from STA
   - Encouragement to follow up with school's financial aid office

**Business Hours Queueing Logic:**
```ruby
# Pseudo-code for email scheduling
application_submitted_at = DateTime.now
alaska_timezone = 'America/Anchorage'

if business_hours?(application_submitted_at, alaska_timezone)
  send_fna_request_immediately
else
  queue_for_next_business_morning(alaska_timezone, 8am)
end

def business_hours?(time, timezone)
  time_in_zone = time.in_time_zone(timezone)
  time_in_zone.wday.between?(1, 5) && # Monday-Friday
  time_in_zone.hour.between?(8, 16)   # 8am-5pm (17:00 = 5pm)
end
```

#### FNA Submission Methods for Schools

**Method 1: Secure Web Form (Preferred)**
- School clicks unique link in email
- Portal displays student information (read-only):
  - Student full name
  - Date of birth
  - School-issued student ID (from application)
- Form fields for FNA data entry (specific fields TBD based on requirements)
- Submit button saves directly to database
- Confirmation message upon successful submission
- Email confirmation sent to school and staff notification triggered

**Method 2: PDF Upload (Backup)**
- Same email includes note: "You may complete the form fields OR upload a completed PDF - no need to do both"
- School can download blank FNA PDF, fill out, and upload via same secure link
- Upload interface accepts PDF files
- Staff approval required for PDF submissions (manual review)

**Method 3: Email Reply (Fallback)**
- School can reply to email with completed PDF attached
- Staff receives notification of email reply
- Manual processing required

#### FNA Status Tracking

**Database Fields:**
```ruby
applications (add FNA tracking fields)
  - fna_request_sent_at (datetime - when email sent to school)
  - fna_request_status (enum: pending, school_submitted, staff_approved, bounced, student_followup)
  - fna_submitted_at (datetime - when school completed form/uploaded PDF)
  - fna_submission_method (enum: webform, pdf_upload, email_reply, manual_entry)
  - fna_verified_by_staff_id (foreign key -> users.id)
  - fna_verified_at (datetime)

fna_verifications (new table - detailed tracking)
  - id (primary key)
  - application_id (foreign key -> applications.id)
  - school_email (email address FNA request sent to)
  - submission_method (enum: webform, pdf_upload, email_reply, manual_entry)
  - submitted_by_email (email of school staff who submitted)
  - submitted_at (datetime)
  - ip_address (for webform security tracking)
  - verified_by_staff_id (foreign key -> users.id)
  - staff_notes (text)
  - created_at, updated_at
```

#### FNA Bounce/No Response Handling

**Automatic Follow-Up Workflow:**

**Trigger:** 7 days after FNA request sent with no response

**Automated Actions:**
1. Update application status: `fna_request_status = 'student_followup'`
2. Send email to student with:
   - Notification that school hasn't responded
   - PDF copy of FNA form attached
   - Instructions to personally deliver to school's financial aid office
   - Request for school to submit via web link or return PDF to student
3. Staff notification generated for manual tracking

**Manual Override Option:**
- Staff can manually trigger student followup email any time
- Staff can manually enter FNA data if school provides via phone/fax
- Audit trail for all manual entries

---

### Automated Email & Notification System

#### Core Email Infrastructure

**Single Email Address for All Communications:**
- `scholarships@sitkatribe-nsn.gov` - handles all automated emails
- Replies routed to internal email management system
- Staff can view/respond within application OR via Gmail

**Email Service Integration:**
- Email delivery service with API (SendGrid, Postmark, or similar)
- Tracking capabilities: sent, delivered, opened, bounced, replied
- SPF, DKIM, DMARC authentication for deliverability
- Bounce detection and handling

#### Email Template System

**Template Management:**
```ruby
email_templates (new table)
  - id (primary key)
  - template_name (unique)
  - template_category (enum: fna_request, transcript_request, award_notification,
                        status_update, document_request, general)
  - subject_line (text with variable placeholders)
  - body_text (text with variable placeholders)
  - active (boolean)
  - created_by_admin_id (foreign key -> users.id)
  - created_at, updated_at

# Template variable examples:
# {student_first_name}, {student_last_name}, {application_key}
# {amount_awarded}, {deadline_date}, {school_name}, {upload_link}
```

**Template Features:**
- Staff can create, edit, save custom templates
- Variable insertion: `{student_first_name}`, `{amount_awarded}`, etc.
- Preview capability before sending
- Default templates provided for common scenarios
- Per-application customization option (edit template before sending single email)

**Scheduled Email Sending:**
- Staff can schedule emails to send at future date/time
- Useful for end-of-semester transcript requests
- Example: "Send transcript request emails on December 20, 2025 at 8:00am Alaska Time"
- Bulk schedule: "Send to all approved applications when semester ends"

#### Bulk Email Operations

**Bulk Send Workflow:**
1. Staff selects multiple applications (checkboxes or filters)
2. Choose email template from dropdown
3. Preview merged emails with student-specific data
4. Option to schedule for future or send immediately
5. Confirm and send
6. Track delivery status for all emails

**Bulk Send Options:**
- Send to all applications in specific status (e.g., all "approved" applications)
- Send to filtered list (by date range, school, status, etc.)
- Schedule bulk send for specific date/time
- Preview individual emails before bulk send

#### Email Logging & Tracking

```ruby
email_logs (new table - comprehensive audit trail)
  - id (primary key)
  - application_id (foreign key -> applications.id)
  - student_id (foreign key -> students.id)
  - email_type (enum: fna_request, transcript_request, award_notification, status_update,
                document_request, general, scheduled)
  - template_id (foreign key -> email_templates.id)
  - sent_to (email address)
  - sent_from ('scholarships@sitkatribe-nsn.gov')
  - subject_line (text - actual subject sent)
  - sent_at (datetime)
  - scheduled_for (datetime - if scheduled send)
  - delivery_status (enum: queued, sent, delivered, opened, bounced, failed, replied)
  - delivered_at (datetime)
  - opened_at (datetime)
  - bounced_at (datetime)
  - bounce_reason (text)
  - replied_at (datetime)
  - sent_by_staff_id (foreign key -> users.id - who triggered send)
  - created_at, updated_at

# Indexes for performance
- Index on application_id
- Index on email_type
- Index on delivery_status
- Index on sent_at
```

---

### Secure Multi-Document Upload Portal

#### Portal Architecture

**Two Portal Types:**

##### 1. FNA Upload Portal (For Schools)
**URL Format:** `https://sta-scholarships.org/fna-submit/{unique_token}`

**Features:**
- Displays student identification (name, DOB, school-issued student ID)
- Two submission options clearly presented:
  - **Option A:** Fill out web form with FNA fields
  - **Option B:** Upload completed FNA PDF
  - Note: "Complete EITHER the form OR upload the PDF - no need to do both"
- Single-use token (expires after successful submission)
- Token expires after 30 days if unused
- Security: IP address logging, submission timestamp

##### 2. Document Upload Portal (For Students/General)
**URL Format:** `https://sta-scholarships.org/upload/{unique_token}`

**Features:**
- Pre-loaded document categories requested in email (e.g., "Transcript", "FAFSA")
- "+" button to add additional document types from dropdown
- Students can upload multiple files per document type
- No limit on number of uploads per category
- File validation: accepted formats (PDF, JPG, PNG), size limits
- Upload progress indicators
- Confirmation message with upload receipt

**Upload Interface Example:**
```
Upload Your Documents - Application #2025-042

Required Documents:
[Transcript - Fall 2024]
  Choose File: [Browse...] [Upload]
  ✓ transcript-fall-2024.pdf uploaded successfully

[FAFSA 2025]
  Choose File: [Browse...] [Upload]

[+ Add Another Document]
  Select type: [Dropdown: Transcript, FAFSA, Course Schedule, Acceptance Letter, Other]
  Choose File: [Browse...] [Upload]

[Submit All Documents]
```

#### Upload Token Management

```ruby
secure_upload_tokens (new table)
  - id (primary key)
  - token (unique, cryptographically random - 32+ characters)
  - application_id (foreign key -> applications.id)
  - student_id (foreign key -> students.id, nullable for school tokens)
  - token_type (enum: fna_school, document_student, transcript_student, general)
  - requested_categories (json array - e.g., ["transcript", "fafsa"])
  - single_use (boolean)
  - used (boolean)
  - used_at (datetime)
  - expires_at (datetime - typically 30 days from creation)
  - created_at, updated_at

# Security indexes
- Index on token (fast lookup)
- Index on expires_at (cleanup job)
- Index on application_id
```

**Token Generation Logic:**
```ruby
# Pseudo-code for secure token generation
def generate_upload_token(application, type:, categories: [], expires_in: 30.days)
  token = SecureRandom.urlsafe_base64(32)

  SecureUploadToken.create!(
    token: token,
    application_id: application.id,
    student_id: application.student_id,
    token_type: type,
    requested_categories: categories,
    single_use: (type == 'fna_school'), # FNA tokens are single-use
    expires_at: Time.now + expires_in
  )

  generate_upload_url(token)
end
```

#### Upload Confirmation & Receipts

**Immediate Confirmation:**
- On-screen success message after upload
- Automatic confirmation email to uploader
- Email includes: upload date/time, file names, next steps

**Confirmation Email Content:**
```
Subject: Document Upload Confirmation - STA Scholarship Application

Thank you for uploading your documents for the Sitka Tribe of Alaska scholarship application.

Documents Received:
- Transcript - Fall 2024.pdf (uploaded Dec 15, 2025 at 2:30pm)
- FAFSA 2025.pdf (uploaded Dec 15, 2025 at 2:32pm)

Next Steps:
Our staff will review your documents within 5 business days. You will receive an email update once the review is complete.

If you have questions, please contact us at scholarships@sitkatribe-nsn.gov

Sitka Tribe of Alaska Education Department
```

---

### Global Notifications Center

#### Notification Architecture

**System-Wide Staff Notifications:**
- All staff see same notifications (not personalized per user)
- Notifications persist until manually approved/dismissed by any staff member
- Real-time indicators when another staff member is viewing a notification

**Notification Categories:**
```ruby
notifications (new table)
  - id (primary key)
  - notification_type (enum: email_sent, email_received, email_reply, document_uploaded,
                        fna_submitted, application_submitted, application_archived,
                        board_vote_complete, award_notification_sent, transcript_received,
                        system_action, critical_item)
  - application_id (foreign key -> applications.id, nullable)
  - student_id (foreign key -> students.id, nullable)
  - related_email_id (foreign key -> email_logs.id, nullable)
  - title (text - short description)
  - message (text - full notification content)
  - priority (enum: low, normal, high, critical)
  - status (enum: pending, viewed, approved, dismissed)
  - currently_viewing_by (foreign key -> users.id, nullable - who is currently viewing)
  - viewed_by_staff_id (foreign key -> users.id - who clicked to view)
  - viewed_at (datetime)
  - approved_by_staff_id (foreign key -> users.id - who approved/dismissed)
  - approved_at (datetime)
  - created_at, updated_at

# Indexes
- Index on status (filter pending vs approved)
- Index on notification_type
- Index on priority
- Index on application_id
```

#### Notification Display

**Dropdown Menu (Quick View):**
- Icon in top navigation with badge count (e.g., "🔔 12")
- Click to see recent 10 notifications
- "View All" link to full notifications center page

**Full Notifications Center Page:**
- All pending notifications listed
- Filters: by type, priority, date range
- Search functionality
- Sortable columns
- Batch approve/dismiss capability

**Notification Item Display:**
```
🔴 Document Uploaded - High Priority
Application #2025-042 - Jane Doe
Transcript uploaded via secure link on Dec 15, 2025 at 2:30pm
Currently viewing: John Smith

Actions:
[View Document] [View Application] [View Email Thread] [Approve] [Dismiss]
```

**"Currently Viewing" Indicator:**
- Real-time websocket/polling updates
- Shows: "Currently viewing: John Smith" when another staff member has notification open
- Prevents duplicate work
- Updates automatically when staff member navigates away

#### Notification Audit Log

**Separate Archive for Approved/Dismissed Notifications:**
```ruby
notification_audit_log (view or table)
  - All fields from notifications table
  - Filterable by date range, type, staff member
  - Search by application number or student name
  - Export capability for reporting
```

**Staff Interface:**
- Tab navigation: "Pending Notifications" | "Audit Log"
- Audit log read-only
- Full search and filter capabilities
- Permanent record retention

#### Critical Email Notifications to Staff

**Staff Email Alerts for Critical Items:**
- New application submitted (immediate notification to all staff)
- FNA bounced from school (send to all staff)
- Board voting complete for application (send to all staff)
- Transcript deadline approaching (7 days before)
- Document uploaded pending approval

**Email Notification Settings:**
```ruby
system_settings (extend existing table)
  - setting_key: 'staff_email_notifications'
  - setting_value: {
      new_application: true,
      fna_bounced: true,
      board_vote_complete: true,
      transcript_deadline: 7, # days before deadline
      document_uploaded: true
    }
```

---

### Document Status Display Integration

#### Status Display on All Three Key Pages

**1. Email Monitoring Dashboard (Dedicated Page)**
- Full email history for all applications
- Filter by email type, status, date range
- Sortable table showing:
  - Application #
  - Student Name
  - Email Type (FNA Request, Transcript Request, Award Notification, etc.)
  - Sent Date
  - Delivery Status (Sent, Delivered, Opened, Bounced, Replied)
  - Actions (View Email, View Application, Resend)

**2. Verification Workflow Page**
- Compact status indicators for each application in workflow table
- Key status fields shown:
  - **FAFSA Status:** ✓ Received | ⏳ Requested (Dec 10) | ✗ Missing
  - **FNA Request Status:** ✓ School Submitted (Dec 12) | ⏳ Sent (Dec 8) | ⚠️ Bounced
  - **Transcript Status:** ✓ Fall Received | ⏳ Requested (Dec 15) | ✗ Missing
  - **Award Notification:** ✓ Sent (Dec 20) | ⏳ Pending | Not Sent
- Totals display: Budget Forecast total vs FNA total for comparison

**3. Individual Application Page**
- Detailed status section showing complete timeline:

```
Document & Communication Status

FAFSA
  Status: ✓ Received
  Uploaded: Dec 10, 2025 at 9:45am via secure link
  Reviewed by: Sarah Johnson (Dec 11, 2025)

Financial Needs Analysis (FNA)
  Student Budget Forecast Total: $28,500
  School FNA Total: $30,200

  Request Status: ✓ School Submitted
  Sent to school: Dec 8, 2025 at 8:00am
  Delivered: Dec 8, 2025 at 8:02am
  School submitted: Dec 12, 2025 at 2:15pm
  Reviewed by: Sarah Johnson (Dec 13, 2025)

Transcript - Fall 2024
  Status: ✓ Received
  Requested: Dec 15, 2025 at 8:00am
  Opened by student: Dec 15, 2025 at 10:30am
  Uploaded: Dec 15, 2025 at 2:30pm via secure link
  Reviewed by: Michael Chen (Dec 16, 2025)

Award Notification
  Status: ✓ Sent
  Sent: Dec 20, 2025 at 9:00am
  Delivered: Dec 20, 2025 at 9:05am
  Opened: Dec 20, 2025 at 11:30am
```

---

### Email Reply Handling & Interface

#### Email Thread Management

**Two-Way Email Access:**

**Option 1: In-System Email Interface**
- Dedicated email management page within application
- View full email threads for each application
- Reply directly from interface (sends from scholarships@sitkatribe-nsn.gov)
- Email composition with rich text editor
- Attachment support
- Email history preserved in database

**Option 2: External Gmail Access**
- Staff can access scholarships@sitkatribe-nsn.gov via Gmail
- All emails visible in Gmail interface
- Replies sent via Gmail are tracked in system (via email service API webhooks)
- No manual import required

#### Reply Notification Workflow

**When School/Student Replies to Email:**

1. **Email Service Webhook** detects incoming reply
2. **Notification Created** in system:
   - Type: "Email Reply Received"
   - From: sender's email address
   - Application: linked application number
   - Preview: first 200 characters of email body
3. **Staff Notification** appears in dropdown and notifications center
4. **Click Notification** → Options:
   - "View Email in System" → Opens internal email interface showing full thread
   - "View Application" → Opens application page
   - Email also visible in Gmail if staff prefers

**Notification Display Example:**
```
📧 Email Reply Received - Normal Priority
Application #2025-042 - Jane Doe
From: finaid@university.edu
Subject: Re: Financial Needs Analysis Request

Preview: "Thank you for your request. We have completed the FNA form and uploaded it via your secure link..."

Actions:
[View Email Thread] [View Application] [Mark as Read]
```

**Email Parsing:**
- No automatic parsing of email content into application fields
- Staff reads email manually (either in system or Gmail)
- Email thread preserved for audit trail
- Attachments accessible from email interface

---

### Award Notification Workflow & Tracking

#### Award Notification Process

**Trigger:** Staff sends award notification (single or bulk)

**Automated Actions:**
1. Email sent from template with student-specific data
2. `award_notification_sent` flag updated on application
3. `award_notification_sent_at` timestamp recorded
4. Email log created for tracking
5. Notification generated for staff confirmation

**Application Status Updates:**
```ruby
applications (add award notification tracking)
  - award_notification_sent (boolean - default false)
  - award_notification_sent_at (datetime)
  - award_notification_sent_by_staff_id (foreign key -> users.id)
  - award_notification_email_id (foreign key -> email_logs.id)
```

**Display on Verification Page:**
- Column showing: "Award Notif: ✓ Sent (Dec 20)" or "Not Sent"
- Filter option: "Show only applications with notifications sent"
- Bulk action: "Send Award Notifications" (select multiple, send all at once)

**Display on Application Page:**
```
Award Notification Status

Status: ✓ Notification Sent
Sent Date: December 20, 2025 at 9:00am
Sent By: Sarah Johnson
Template Used: Award Approval - Standard
Delivery Status: Delivered and Opened (Dec 20, 2025 at 11:30am)

Award Details:
Regular Scholarship: $3,000
ARPA Funding: $2,000
Total Award: $5,000

[View Email] [Resend Notification]
```

#### Award Notification and Lifetime Tracking Integration

**Current Requirement:** Award notification and disbursement tracking are **separate** (subject to change based on staff feedback)

**When Award Notification Sent:**
- Application marked with `award_notification_sent = true`
- Lifetime totals (`students.total_undergrad_awarded` or `students.total_grad_awarded`) **already updated** when award was verified/approved
- Award notification is informational to student, not a trigger for financial tracking
- Disbursement tracking happens separately (when actual payment made, tracked in `student_financial_tracking`)

**Future Consideration:**
- May combine award notification with disbursement status update
- May trigger automatic lifetime total update on notification send (instead of verification)
- Database structure supports either workflow without changes

---

### School Financial Aid Office Database

#### Verified School Contacts

```ruby
schools (new table)
  - id (primary key)
  - school_name (text)
  - school_type (enum: university, community_college, vocational, high_school)
  - financial_aid_office_email (text)
  - financial_aid_office_phone (text)
  - address (text)
  - city, state, zip_code
  - verified (boolean - staff has confirmed contact info is current)
  - verified_at (datetime)
  - verified_by_staff_id (foreign key -> users.id)
  - notes (text - contact person names, special instructions)
  - created_at, updated_at

# Common schools pre-populated:
# - University of Alaska Anchorage (UAA)
# - University of Alaska Fairbanks (UAF)
# - University of Alaska Southeast (UAS)
# - Other frequently attended institutions
```

**Integration with Application Form:**
- Student selects school from dropdown (autocomplete)
- If school in database: auto-populate financial aid office email
- If school not in database: student enters school name manually, staff adds to database later
- FNA request emails use verified email addresses when available
- Reduces bounce rate, improves delivery

---

### Email Deliverability & Monitoring

#### Email Authentication Setup

**Domain Configuration:**
- **SPF Record:** Authorizes email service to send from sitkatribe-nsn.gov domain
- **DKIM Signature:** Cryptographic signature validates email authenticity
- **DMARC Policy:** Instructs receiving servers how to handle authentication failures
- Reduces spam folder delivery, improves open rates

**Bounce Handling:**
- Automatic bounce detection via email service webhooks
- Hard bounces (invalid email address): flag for immediate staff review
- Soft bounces (temporary issues): retry delivery, flag if persistent
- Update `delivery_status` in `email_logs` table

**Deliverability Monitoring Dashboard:**
- Bounce rate tracking (target: <2%)
- Open rate statistics
- Delivery success rate
- Blacklist monitoring (automated alerts if domain flagged)

---

### Implementation Priority

**Phase 5.5 or Phase 6: Email & Document System**
- Email template management system
- FNA request workflow (automatic email to schools)
- Secure upload portal (FNA and general documents)
- Email logging and tracking
- Basic notification center

**Phase 7 Integration: Verification Workflow Enhancement**
- Document status display on verification page
- Email status indicators
- Bulk email operations
- Advanced notification features (currently viewing, audit log)

**Phase 8: Advanced Features**
- Email reply parsing improvements
- Advanced analytics on email engagement
- SMS notifications (future enhancement)
- School database management interface

---

### Database Schema Summary - Email & FNA System

**New Tables:**
```ruby
email_templates
  - id, template_name, template_category, subject_line, body_text
  - active, created_by_admin_id, created_at, updated_at

email_logs
  - id, application_id, student_id, email_type, template_id
  - sent_to, sent_from, subject_line
  - sent_at, scheduled_for, delivery_status
  - delivered_at, opened_at, bounced_at, bounce_reason, replied_at
  - sent_by_staff_id, created_at, updated_at

secure_upload_tokens
  - id, token, application_id, student_id, token_type
  - requested_categories (json), single_use, used, used_at
  - expires_at, created_at, updated_at

fna_verifications
  - id, application_id, school_email, submission_method
  - submitted_by_email, submitted_at, ip_address
  - verified_by_staff_id, staff_notes, created_at, updated_at

notifications
  - id, notification_type, application_id, student_id, related_email_id
  - title, message, priority, status
  - currently_viewing_by, viewed_by_staff_id, viewed_at
  - approved_by_staff_id, approved_at, created_at, updated_at

schools
  - id, school_name, school_type, financial_aid_office_email
  - financial_aid_office_phone, address, city, state, zip_code
  - verified, verified_at, verified_by_staff_id, notes
  - created_at, updated_at
```

**Extended Tables:**
```ruby
applications (add fields)
  - fna_request_sent_at, fna_request_status, fna_submitted_at
  - fna_submission_method, fna_verified_by_staff_id, fna_verified_at
  - award_notification_sent, award_notification_sent_at
  - award_notification_sent_by_staff_id, award_notification_email_id

system_settings (add configuration)
  - Business hours configuration (Alaska timezone, 8am-5pm)
  - Email notification preferences for staff
  - Upload token expiration settings
  - Email template defaults
```

---

## Benefits of New Schema

### Immediate Benefits
- **Better File Organization** - Categorized uploads with admin visibility
- **Student Tracking** - Ability to see multiple applications per student
- **Cleaner Relationships** - Proper foreign keys and associations

### Future Benefits
- **Student Profile Pages** - Complete history and contact management
- **Multi-Year Applications** - Easy renewal and tracking
- **Better Reporting** - Normalized data for analytics
- **Performance** - Indexed relationships for faster queries

### Long-Term Possibilities
- **Save & Resume** - Easier with separated student profile
- **Batch Operations** - Process multiple applications efficiently
- **Data Analytics** - Better insights with normalized structure
- **API Development** - Clean relationships for external integrations

## Risk Assessment

### Low Risk
- No live data to migrate
- Compatibility layer ensures existing functionality works
- Can rollback instantly if issues arise

### Medium Risk
- File upload system changes might need thorough testing
- Admin interface updates require careful validation

### Mitigation Strategies
- Comprehensive testing at each phase
- Keep old schema until everything is proven working
- Implement changes gradually with validation at each step

## Success Metrics

### Phase Completion Criteria
1. **Phase 1:** New tables created, migrations run successfully
2. **Phase 2:** All existing functionality works with adapter layer
3. **Phase 3:** File uploads work with categorization
4. **Phase 4:** Admin can create and view applications using new schema
5. **Phase 5:** Old table removed, system runs on new schema only

### Validation Checkpoints
- Form submission creates proper student and application records
- Admin interface displays all data correctly
- File uploads associate with correct application
- All existing URLs and functionality preserved
- CSV export works with new schema

## Next Steps

1. **Start Phase 1** - Create new database tables and models
2. **Build Phase 2** - Implement compatibility adapter layer
3. **Test Everything** - Ensure no functionality is broken
4. **Continue Through Phases** - Gradual, careful refactoring

---

## Implementation Log

### Session 1: Planning Phase ✅
- **Date:** 2025-09-09
- **Completed:** Requirements gathering and schema design
- **Next:** Begin Phase 1 implementation

### Session 2: Environment Setup ✅
- **Date:** 2025-12-22
- **Completed:** Verified Docker environment (Ruby 3.3.8, Rails 8.0.1) 
- **Completed:** Identified CSV export issues and documented requirements
- **Status:** Ready to begin Phase 1 implementation

### Session 3: Complete Planning Review ✅
- **Date:** 2025-12-23
- **Completed:** Comprehensive plan review and validation
- **Completed:** Updated schema design with actual field counts (275+ fields verified)
- **Completed:** Integrated financial tracking, file management, and historical import requirements
- **Status:** Planning complete - Ready for implementation phase review and finalization

### Session 4: [Next - Tomorrow]
- **Planned:** Finalize Implementation Plan phases and begin Phase 1 development
- **Status:** Ready to continue

---

## Notes and Considerations

### Staff Dashboard Tracking
- Mentioned as separate from general admin dashboard
- Deferred to future implementation
- May have some overlap with admin functionality
- Needs further requirements gathering when ready to implement

### Form Evolution
- Current: Single large form submission (keep for now)
- Future: Multi-step form with save/resume capability
- New schema will support both approaches
- Save/resume will be much easier with student profile separation

### Data Validation
- Tribal ID uniqueness enforcement
- Application key generation strategy
- File upload validation and size limits
- Financial data integrity checks

### CSV Export System Issues
**Current Problems (Legacy System):**
- Export functionality is broken - exports database in 1-2 columns instead of proper format
- Uses `Array(params[:columns])` with frontend column selection that doesn't work properly
- No validation of selected columns
- Exports ALL applications with only selected fields (not useful)
- Missing proper headers and field mapping
- No single application export capability

**Required Export Functionality:**
1. **Single Application Export** - Complete application data for individual review/verification
2. **Bulk Application Export** - All applications with all relevant fields for analysis
3. **Staff Verification Template System** - Comprehensive verification workflow (see detailed spec below)
4. **Custom Field Selection** - Allow admins to choose which fields to export

### Staff Verification Template System - Complete Specification

**Core Concept:**
- Each application submission gets its own unique verification template
- Templates persist with applications permanently for audit trail
- Primary staff workflow for application processing

**Verification Template Components:**
1. **Web-Based Verification Interface**
   - Hosted directly on website (not just downloadable)
   - Shows ALL current applications with verification templates in one interface
   - Staff can work through applications one-by-one manually
   - Checkboxes/fields for verification steps (document completeness, eligibility checks, etc.)
   - Auto-saves progress as staff completes verification for each application
   - Template structure includes verification checklist items

2. **Student Profile Integration**
   - **Student Profile Page**: Displays ALL verification templates for student's applications (current + historical) in chronological order
   - **Individual Application View**: Shows verification template for that specific application only
   - **Historical Context**: Staff can review verification details from past applications when processing new ones

3. **Export Capabilities**
   - **Single Application**: Download verification template CSV for one specific application with current completion status
   - **Single Student Bulk**: Download ALL verification templates for one student (current + historical applications)
   - **Current Applications Bulk**: Download ALL verification templates for current application cycle with completion status
   - **Historical Bulk**: Download verification templates for any specified date range or application cycle

**Database Schema Requirements (for new normalized structure):**
```ruby
verification_templates
  - id (primary key)
  - application_key (foreign key -> applications.application_key)
  - template_data (JSON field for verification checklist items)
  - completion_status (enum: not_started, in_progress, completed)
  - verified_by_staff_id
  - verification_started_at
  - verification_completed_at
  - notes (text field for staff comments)
  - created_at, updated_at
```

**Staff Workflow Benefits:**
- **Bulk Processing**: Process multiple applications efficiently in single interface
- **Individual Focus**: Deep dive into specific applications when needed
- **Historical Context**: Review past verification patterns for repeat applicants
- **Audit Trail**: Complete record of who verified what and when
- **Flexible Export**: Get verification data in format needed for reporting or external review

**Implementation Plan (Post-Normalization):**
- Create dedicated `ApplicationExportService` class
- Implement `VerificationTemplateService` for template management
- Build web-based verification interface with auto-save functionality
- Implement proper field mapping and human-readable headers for all export formats
- Create student profile pages with historical verification timeline
- Support multiple export formats with completion status tracking
- CSV export will be much cleaner with normalized schema relationships

**Priority:** Defer until after database normalization - new schema will make verification templates and exports significantly easier to implement correctly.

---

## SESSION 3 COMPLETION SUMMARY - WHERE WE LEFT OFF
**Date:** 2025-12-23  
**Status:** Planning phase complete, ready for implementation planning finalization

### What We Accomplished Today
1. **✅ Project Overview Validation** - Confirmed complete database overhaul approach with development freedom
2. **✅ Current State Analysis** - Verified actual schema (275+ fields), identified existing students table foundation
3. **✅ Target Schema Design** - Created comprehensive 6-table normalized structure
4. **✅ Requirements Integration** - Incorporated financial tracking, file management, and historical import needs

### Key Decisions Made
- **Field Compatibility:** Keep all application field names identical for form compatibility
- **Students Table:** Enhance existing table rather than create new one
- **Financial Tracking:** Separate `student_financial_tracking` table with semester breakdown
- **Award System:** Support both regular and ARPA funding pools with verification workflow
- **Historical Data:** Manual import interface integrated into student profile pages
- **File Storage:** Dual attachment (application-specific + student profile) with categorization
- **Application Types:** Distinguish digital vs historical_import applications

### Critical Requirements Clarified
1. **Financial Tracking Logic:**
   - Pull verified amounts from verification workflow (amount_awarded + arpa_amount_awarded)
   - Current applications show "possible amount" separate from totals until verified
   - Support manual entry for historical paper applications (amount_requested + amount_earned)
   - Track undergraduate vs graduate award limits with threshold checking

2. **File Management Strategy:**
   - Transcripts attach to specific applications by semester (Fall 2025 → 2025/2026 application)
   - High school transcripts can go to application OR student profile
   - Student profile displays all files (application-linked + profile-specific)
   - Staff can remove duplicate files

3. **Historical Data Bridge:**
   - Manual entry interface on student profile pages
   - Create profiles anticipating future digital applications
   - Minimal required fields: name, year, tribal_id, school, amounts, dates
   - Links to future applications via tribal_id matching

4. **Staff Verification Workflow:**
   - Web-based interface showing ALL current applications in one place
   - Each application gets unique verification template that persists permanently
   - Auto-saves progress, supports bulk processing + individual focus
   - Student profiles show verification history for all past applications
   - Multiple export options (single app, student bulk, current bulk, historical bulk)

### What's Next Tomorrow
**IMMEDIATE PRIORITY:** Review and finalize Implementation Plan (Phase 4 of planning review)
- Current 5-phase plan needs revision for expanded scope
- Add historical data import interface development
- Add student profile page development  
- Update timeline estimates (original 3-4 sessions too optimistic)
- Determine phase priorities and dependencies

**THEN:** Begin Phase 1 implementation
- Create migration files for new tables
- Build new models with associations and validations
- Keep existing schema untouched during development

### Current Planning Status
- ✅ **Section 1:** Project Overview validated and updated
- ✅ **Section 2:** Current State Analysis validated and updated  
- ✅ **Section 3:** Target Database Schema validated and updated
- ⏳ **Section 4:** Implementation Plan needs revision for expanded scope
- ⏳ **Section 5:** CSV Export and Verification Template specs need final review
- ⏳ **Section 6:** Risk Assessment and Success Metrics need final review

### Important Context for Tomorrow
- **Development Environment:** Docker with Ruby 3.3.8, Rails 8.0.1 - ready to go
- **Current Database:** 275+ field monolithic table + existing students table with financial tracking foundation
- **Application State:** Not deployed/in use - complete freedom to break and rebuild
- **Transition Context:** Moving from paper-based to digital-first scholarship management
- **CSV Export:** Currently broken, needs complete overhaul post-normalization

**Next session should start by reviewing Implementation Plan phases to ensure they align with our comprehensive requirements, then begin actual database development work.**

This comprehensive plan ensures we can safely refactor the database while building the foundation for modern scholarship management with proper student profiles, financial tracking, verification workflows, and historical data integration.