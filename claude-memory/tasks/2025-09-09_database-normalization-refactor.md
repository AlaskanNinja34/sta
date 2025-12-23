# Database Normalization Refactor - STA Scholarship Application System

**Task Created:** 2025-09-09  
**Status:** Planning Complete - Ready for Implementation  
**Estimated Timeline:** Extended timeline - Comprehensive database overhaul with multiple phases  
**Priority:** High - Core architecture improvement and foundation for all future work

## Project Overview

Complete database restructure from monolithic `scholarship_applications` table (320+ fields) into a proper normalized relational database structure. This is a comprehensive overhaul to create a solid foundation for all future development work.

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

## Implementation Plan

### Phase 1: Create New Schema (Non-Breaking)
**Status:** Pending  
**Estimated Time:** 1 session

#### Tasks:
1. **Create Migration Files**
   - `create_students.rb`
   - `create_applications.rb` 
   - `create_application_files.rb`
   - Add indexes on tribal_id, application_key, student_id

2. **Create New Models**
   - `app/models/student.rb`
   - `app/models/application.rb`
   - `app/models/application_file.rb`
   - Set up associations and validations

3. **Keep Existing Schema**
   - Don't touch `scholarship_applications` table yet
   - Existing functionality continues working

### Phase 2: Build Compatibility Layer (Bridge Pattern)
**Status:** Pending  
**Estimated Time:** 1 session

#### Tasks:
1. **Create Data Adapter Service**
   ```ruby
   # app/services/scholarship_application_adapter.rb
   class ScholarshipApplicationAdapter
     # Maps flat scholarship_application data to new normalized structure
     # Handles reads/writes to maintain backward compatibility
   end
   ```

2. **Update ScholarshipApplication Model**
   - Add adapter methods to handle new schema interactions
   - Maintain existing method signatures
   - Add dual-write capability to populate new tables

3. **Test Compatibility**
   - Ensure all existing controllers work unchanged
   - Verify form submissions populate both schemas
   - Test admin interface displays correctly

### Phase 3: Enhance File Upload System
**Status:** Pending  
**Estimated Time:** 0.5 session

#### Tasks:
1. **Update File Upload Views**
   - Separate upload buttons for each file category
   - FAFSA, Transcripts, Course Schedules, Other
   - Show upload status for each category

2. **Update Controllers**
   - Handle categorized file uploads
   - Store files with proper application_key association
   - Update admin views to show categorized files

3. **Admin File Management**
   - Display files by category in admin interface
   - Easy download/view access
   - Upload status indicators

### Phase 4: Gradual Refactoring to New Schema
**Status:** Pending  
**Estimated Time:** 1.5 sessions

#### Tasks:
1. **Update Form Processing**
   - Modify form submission to create student profile if needed
   - Create application record with proper associations
   - Maintain single-form submission experience

2. **Refactor Admin Interface**
   - Update admin views to use new associations
   - Implement student profile pages
   - Show application history per student

3. **Update Controllers**
   - Gradually switch from adapter to direct new schema usage
   - Update search and filtering to work with new structure
   - Maintain all existing functionality

### Phase 5: Clean Up and Optimization
**Status:** Pending  
**Estimated Time:** 0.5 session

#### Tasks:
1. **Remove Compatibility Layer**
   - Remove adapter service once everything uses new schema
   - Clean up any temporary dual-write code

2. **Drop Old Table**
   - Create final migration to drop `scholarship_applications`
   - Ensure no references remain

3. **Optimize New Schema**
   - Add any missing indexes
   - Review and optimize queries
   - Update documentation

## Implementation Details

### Migration Strategy
```ruby
# Step 1: Create new tables alongside existing
# Step 2: Dual-write to both schemas during transition
# Step 3: Switch reads to new schema table by table
# Step 4: Remove old schema once fully migrated
```

### Key Code Changes

**Models to Update:**
- `app/models/scholarship_application.rb` - Add adapter layer
- Create new models for Student, Application, ApplicationFile

**Controllers to Update:**
- `app/controllers/scholarship_applications_controller.rb`
- `app/controllers/admin/scholarship_applications_controller.rb`
- File upload handling

**Views to Update:**
- Form partials for file uploads
- Admin interface for file management
- Student profile pages (new)

### Testing Strategy
1. **Unit Tests** - Test new models and associations
2. **Integration Tests** - Test adapter compatibility layer
3. **System Tests** - Test complete form submission workflow
4. **Manual Testing** - Verify admin interface functionality

### Rollback Plan
- Keep old table until everything is working perfectly
- Adapter layer allows instant rollback to old schema
- New tables can be dropped without affecting existing functionality

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