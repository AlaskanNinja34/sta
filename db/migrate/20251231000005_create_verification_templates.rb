# db/migrate/20251231000005_create_verification_templates.rb
# Phase 1: Create verification templates table
# Extends the AppTable verification workflow with detailed tracking
# Links to applications via application_key

class CreateVerificationTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :verification_templates do |t|
      # === LINKING FIELDS ===
      t.string :application_key, null: false     # Links to applications table

      # === WORKFLOW STATUS ===
      t.string :verification_status, default: 'not_started'  # 'not_started', 'in_progress', 'completed'
      t.boolean :archived, default: false        # Archived after 10-month lifecycle
      t.datetime :archived_at

      # === CHECKLIST DATA (JSON for flexibility) ===
      # Stores verification items with their status, who verified, when, notes
      # Example structure:
      # {
      #   "tribal_id_verified": { "checked": true, "verified_by": "staff@sta.org", "verified_at": "2025-01-15", "notes": "" },
      #   "transcript_reviewed": { "checked": true, "verified_by": "staff@sta.org", "verified_at": "2025-01-15", "notes": "" },
      #   ...
      # }
      t.json :checklist_data, default: {}

      # === PROGRESS TRACKING ===
      t.integer :items_total, default: 0         # Total checklist items
      t.integer :items_completed, default: 0     # Completed checklist items
      t.decimal :completion_percentage, precision: 5, scale: 2, default: 0.0

      # === TIMESTAMPS ===
      t.datetime :verification_started_at
      t.datetime :verification_completed_at
      t.string :completed_by                     # Staff who marked complete

      # === NOTES ===
      t.text :staff_notes                        # General notes about verification
      t.text :issues_found                       # Any issues discovered during verification

      # === AWARD RECOMMENDATION ===
      t.decimal :recommended_award_amount, precision: 10, scale: 2
      t.decimal :recommended_arpa_amount, precision: 10, scale: 2
      t.text :award_notes

      # === AUDIT ===
      t.string :created_by
      t.string :last_modified_by
      t.datetime :last_modified_at

      t.timestamps
    end

    # === INDEXES ===
    add_index :verification_templates, :application_key, unique: true
    add_index :verification_templates, :verification_status
    add_index :verification_templates, :archived
    add_index :verification_templates, [:archived, :verification_status]
  end
end
