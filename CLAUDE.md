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