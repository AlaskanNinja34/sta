# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Application
This is a scholarship application management system for the Sitka Tribe of Alaska (STA), built with Rails 8.0. The system allows students to submit scholarship applications and provides administrative tools for managing and reviewing submissions.

## Development Commands

### Setup and Installation
```bash
chmod +x bin/*         # Make bin files executable
bundle install         # Install Ruby dependencies
bin/rails db:migrate   # Run database migrations
bin/rails db:seed      # Seed database (if needed)
```

### Running the Application
```bash
bin/rails server       # Start development server (localhost:3000)
bin/dev                # Start development server with live reload (if available)
```

### Database Operations
```bash
bin/rails db:create    # Create database
bin/rails db:migrate   # Run migrations
bin/rails db:rollback  # Rollback last migration
bin/rails db:reset     # Drop, create, migrate, and seed
bin/rails console     # Rails console
```

### Testing and Quality
```bash
bin/rails test                    # Run all tests
bin/rails test:system            # Run system tests specifically
bin/rubocop                      # Run RuboCop linter (uses rails-omakase style)
bin/rails test test/models/scholarship_application_test.rb  # Run specific test
brakeman                         # Security vulnerability scanner
```

### Custom Scripts
The `script/` directory contains utility scripts:
- `script/backup-development-database.bash` - Backup development database
- `script/backup-production-database.bash` - Backup production database
- `script/psql-development.bash` - Connect to development PostgreSQL
- `script/build-app-container.bash` - Build Docker container

## Architecture Overview

### Core Model: ScholarshipApplication
The application centers around the `ScholarshipApplication` model with 300+ fields covering:
- Personal information (name, DOB, contact details)
- Education history and goals
- Financial needs analysis (FNA) with detailed budget breakdown
- Various forms and releases (photo, parental, ARPA authorization)
- Administrative fields (status tracking, board decisions, award amounts)

### Controllers Structure
- `ScholarshipApplicationsController` - Student-facing application submission and status checking
- `Admin::ScholarshipApplicationsController` - Administrative interface for reviewing applications
- `Admin::DashboardController` - Admin dashboard overview
- `HomeController` - Landing page

### Views Organization
- Student views: Application form broken into logical sections (`_form_*` partials)
- Admin views: Detailed application review with sectioned display (`_show_*` partials)
- Responsive design using CSS with custom fonts (Alegreya family)

### Database Schema
Uses PostgreSQL in production, SQLite3 for development/test. Key features:
- Single large `scholarship_applications` table with comprehensive fields
- Active Storage integration for file uploads
- Indexed fields: `board_status`, `finance_grant_number`

### Routes Structure
```
/ (root)                           # Home page
/scholarship_applications/new      # Application form
/scholarship_applications/:id      # View submitted application
/check_status                      # Status lookup form
/admin/dashboard                   # Admin dashboard
/admin/scholarship_applications    # Admin application management
```

### Technology Stack
- **Framework**: Rails 8.0 with modern defaults
- **Database**: PostgreSQL (production), SQLite3 (development/test)
- **Frontend**: Stimulus, Turbo, Importmap (no bundler)
- **Styling**: Custom CSS with Propshaft asset pipeline
- **File Storage**: Active Storage for document uploads
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Deployment**: Docker with Kamal, Thruster for production optimization

### Form Sections
The scholarship application form is divided into logical sections:
- Applicant Information
- Address Information  
- Education History
- College Details
- Educational Goals
- Budget Forecast
- Financial Needs Analysis (detailed by semester)
- Enrollment Verification
- Various Release Forms
- ARPA Higher Education Scholarship section

## Development Notes

### File Upload Handling
Applications support multiple file uploads via Active Storage. Files are displayed in admin interface with view/download capabilities.

### Status Management
Applications progress through various statuses managed via admin interface:
- Initial: "submitted"
- Admin actions: approve, reject, request more info
- Board decisions tracked in `board_status` field

### Financial Analysis
Complex financial needs analysis with semester-by-semester breakdown of:
- Resources (family contribution, savings, scholarships, loans, etc.)
- Expenses (tuition, room/board, books, transportation, etc.)
- Automatic calculations for totals and unmet need

### Admin Features
- Bulk status updates
- CSV export functionality
- Detailed application review interface
- File management and viewing
- Search and filtering capabilities

---

# COMPREHENSIVE APPLICATION PLANNING

## Application Flow & User Journey

### Student Application Journey
1. **Discovery & Access**
   - Landing page introduces scholarship program
   - Clear navigation to application form
   - Status check functionality for returning users

2. **Application Submission Process**
   - Progressive form completion with logical sections
   - Save & resume functionality (planned enhancement)
   - Real-time validation and error handling
   - File upload requirements clearly communicated
   - Final review before submission

3. **Post-Submission Experience**
   - Immediate confirmation with application ID
   - Status tracking capability
   - Email notifications for status changes (planned)
   - Clear communication of next steps and timelines

### Administrative Workflow
1. **Application Intake**
   - Automatic notification of new submissions
   - Initial completeness review
   - Document verification process
   - Status update to "under review"

2. **Review Process**
   - Detailed application review interface
   - Financial needs analysis validation
   - Supporting document verification
   - Internal notes and scoring system (planned)

3. **Decision Making**
   - Board review preparation
   - Status updates and decision recording
   - Award amount determination
   - Final approval/rejection process

4. **Communication & Distribution**
   - Automated notification system (planned)
   - Award letter generation (planned)
   - Fund disbursement tracking (planned)

## Core Functionality Requirements

### Current System Capabilities
✅ **Implemented Features:**
- Complete scholarship application form (300+ fields)
- File upload system for supporting documents
- Administrative dashboard and review interface
- Basic status management system
- CSV export functionality
- PostgreSQL production database
- Docker deployment with Kamal

### Priority Enhancement Areas

#### Phase 1: User Experience Improvements
🔄 **In Planning:**
- **Save & Resume Functionality**
  - Session-based draft saving
  - User authentication for application retrieval
  - Draft expiration management

- **Enhanced Status Communication**
  - Email notification system
  - SMS notifications (optional)
  - Detailed status descriptions
  - Timeline visualization

- **Application Validation**
  - Real-time form validation
  - Required field indicators
  - File format/size validation
  - Completion progress tracking

#### Phase 2: Administrative Enhancements
🔄 **Planned Features:**
- **Advanced Review Tools**
  - Scoring/rating system
  - Review assignment workflow
  - Internal notes and comments
  - Review history tracking

- **Reporting & Analytics**
  - Application statistics dashboard
  - Financial analysis reports
  - Demographic reporting
  - Award distribution analysis

- **Communication Tools**
  - Automated email templates
  - Bulk communication system
  - Document generation (award letters)
  - Applicant messaging system

#### Phase 3: Advanced Features
🚀 **Future Enhancements:**
- **Multi-Year Application Management**
  - Renewal application tracking
  - Historical scholarship records
  - Academic progress monitoring
  - Alumni tracking system

- **Integration Capabilities**
  - Financial aid office integration
  - Academic institution APIs
  - Payment processing integration
  - Document management system

- **Advanced Analytics**
  - Machine learning for application screening
  - Predictive analytics for funding needs
  - Success rate analysis
  - ROI tracking for scholarship program

## Technical Architecture Planning

### Database Evolution Strategy
**Current State:** Single comprehensive `scholarship_applications` table

**Planned Improvements:**
1. **Data Normalization (Phase 2)**
   - Extract recurring entities (schools, programs)
   - Implement proper foreign key relationships
   - Add audit trail tables
   - Create lookup tables for standardized data

2. **Performance Optimization**
   - Add strategic indexes for common queries
   - Implement database partitioning for large datasets
   - Query optimization for reporting features
   - Caching strategy for frequently accessed data

### Security & Compliance Framework
**Current:** Basic Rails security defaults

**Enhancement Plan:**
1. **Data Protection**
   - Field-level encryption for sensitive data
   - Audit logging for all data access
   - Regular security vulnerability scanning
   - GDPR/privacy compliance measures

2. **Access Control**
   - Role-based permissions system
   - Multi-factor authentication
   - Session management improvements
   - API security (if external integrations added)

### Frontend Architecture Evolution
**Current:** Server-side rendered Rails with Stimulus/Turbo

**Planned Enhancements:**
1. **Progressive Enhancement**
   - Enhanced Stimulus controllers for complex interactions
   - Improved form validation and user feedback
   - Better mobile responsiveness
   - Accessibility compliance (WCAG 2.1)

2. **Performance Optimization**
   - Asset optimization and compression
   - Progressive loading for large forms
   - Offline capability for form completion
   - Performance monitoring and optimization

## Development Methodology & Change Management

### Development Workflow
1. **Planning Phase**
   - Feature requirement documentation in CLAUDE.md
   - Technical specification creation
   - Timeline and resource estimation
   - Stakeholder approval process

2. **Implementation Phase**
   - Feature branch development
   - Test-driven development approach
   - Code review and quality assurance
   - Staging environment validation

3. **Deployment Phase**
   - Production deployment with rollback plan
   - User acceptance testing
   - Performance monitoring
   - Documentation updates

### Quality Assurance Strategy
**Testing Framework:**
- Unit tests for all models and business logic
- Integration tests for complete workflows
- System tests for user interface validation
- Performance testing for scalability

**Code Quality:**
- RuboCop for style consistency
- Brakeman for security scanning
- Code coverage monitoring
- Regular dependency updates

### Data Management & Migration Strategy
**Backup & Recovery:**
- Automated daily database backups
- Point-in-time recovery capability
- Disaster recovery procedures
- Data migration testing protocols

**Version Control:**
- Git-based development workflow
- Comprehensive commit messaging
- Release tagging and documentation
- Change log maintenance

## Stakeholder Communication Plan

### Regular Reporting
- Monthly development progress reports
- Quarterly feature roadmap updates
- Annual system performance reviews
- User feedback collection and analysis

### Documentation Strategy
- Technical documentation maintenance
- User guide creation and updates
- Administrator training materials
- API documentation (for future integrations)

### Training & Support
- Administrator training for new features
- User support documentation
- Help desk procedures
- Change management communication

## Success Metrics & KPIs

### Application Process Metrics
- Application completion rates
- Time to complete application
- Error rates and abandonment points
- User satisfaction scores

### Administrative Efficiency
- Application processing time
- Review workflow efficiency
- Communication response times
- System uptime and performance

### Program Impact Measurement
- Scholarship distribution analysis
- Student success tracking
- Program ROI measurement
- Long-term impact assessment

---

# DEVELOPMENT CHANGE LOG

## Version History
- **v1.0** - Initial application system with basic functionality
- **v1.1** - Enhanced admin interface and CSV export
- **v2.0** - Planned: Save/resume functionality and email notifications
- **v2.1** - Planned: Advanced review tools and reporting
- **v3.0** - Planned: Multi-year tracking and integrations

## Future Milestones
- **Q1 2025:** Phase 1 enhancements (UX improvements)
- **Q2 2025:** Phase 2 administrative tools
- **Q3 2025:** Advanced reporting and analytics
- **Q4 2025:** Multi-year application management

This planning document serves as our comprehensive roadmap for the STA scholarship application system development and will be updated as requirements evolve and new features are implemented.

---

# Claude Memory System

This directory contains task-specific memory files for Claude Code interactions. Each task gets its own dedicated file for planning, tracking changes, and maintaining context.

## Directory Structure

```
claude-memory/
├── README.md              # This file - usage documentation
├── TASK_TEMPLATE.md       # Template for new task files
└── tasks/                 # Individual task memory files
    ├── YYYY-MM-DD_task-name.md
    └── ...
```

## Usage Workflow

### 1. Starting a New Task
1. Copy `TASK_TEMPLATE.md` to `tasks/YYYY-MM-DD_task-name.md`
2. Fill in the task overview and planning phase
3. Break down the work into specific steps
4. Document planned file changes

### 2. During Implementation
- Log all changes made with timestamps
- Document any issues encountered and solutions
- Update progress status regularly
- Reference specific file paths and line numbers

### 3. Task Completion
- Summarize what was accomplished
- Document any outstanding items
- Record metrics (time spent, files changed)
- Mark status as completed

## File Naming Convention

Use the format: `YYYY-MM-DD_descriptive-task-name.md`

Examples:
- `2025-08-13_add-email-notifications.md`
- `2025-08-13_fix-validation-errors.md`
- `2025-08-13_refactor-admin-dashboard.md`

## Benefits

- **Context Preservation:** Maintain detailed records of all changes
- **Planning Documentation:** Think through implementations before coding
- **Problem Resolution:** Track solutions to common issues
- **Progress Tracking:** Clear visibility into task completion
- **Knowledge Transfer:** Detailed logs for future reference

## Integration with CLAUDE.md

This memory system complements the main `CLAUDE.md` file:
- `CLAUDE.md`: Contains high-level project context and development guidelines
- `claude-memory/`: Contains specific task implementation details and change logs

## Best Practices

1. **Always plan before implementing** - Use the planning phase to think through changes
2. **Log changes immediately** - Don't wait until the end to document what you did
3. **Be specific** - Include file paths, line numbers, and exact changes made
4. **Track time** - Record how long different phases take for better estimation
5. **Reference commits** - Link to git commits when applicable
6. **Update status regularly** - Keep the status field current throughout the task