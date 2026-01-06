# db/migrate/20251231000001_drop_scholarship_applications.rb
# Phase 1: Remove the old monolithic scholarship_applications table
# This table is being replaced by the normalized 'applications' table
# Old migration files are kept for reference but this table is no longer needed

class DropScholarshipApplications < ActiveRecord::Migration[8.0]
  def up
    drop_table :scholarship_applications, if_exists: true
  end

  def down
    # This migration is intentionally not reversible
    # The old table structure is preserved in historical migration files for reference
    raise ActiveRecord::IrreversibleMigration, "Cannot recreate scholarship_applications - use original migrations if needed"
  end
end
