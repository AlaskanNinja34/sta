# db/migrate/20251231000004_create_application_files.rb
# Phase 1: Create application files table
# Provides categorized file storage linked by application_key
# Works with both digital applications (YYYY-NNN) and historical imports (HIST-YYYY-NNN)

class CreateApplicationFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :application_files do |t|
      # === LINKING FIELDS ===
      t.string :application_key, null: false     # Links to applications or historical_applications

      # === FILE INFORMATION ===
      t.string :file_category, null: false       # Category of file (see list below)
      t.string :original_filename                # Original name of uploaded file
      t.string :content_type                     # MIME type
      t.integer :file_size                       # Size in bytes
      t.string :storage_key                      # ActiveStorage blob key or S3 key

      # === METADATA ===
      t.string :description                      # Optional description
      t.boolean :required, default: false        # Is this file required?
      t.boolean :verified, default: false        # Has staff verified this file?
      t.datetime :verified_at
      t.string :verified_by                      # Staff who verified

      # === AUDIT ===
      t.string :uploaded_by                      # Who uploaded (student email or staff)
      t.datetime :uploaded_at

      t.timestamps
    end

    # === INDEXES ===
    add_index :application_files, :application_key
    add_index :application_files, :file_category
    add_index :application_files, [:application_key, :file_category]

    # === FILE CATEGORIES (for reference) ===
    # - transcript_official      : Official transcripts
    # - transcript_unofficial    : Unofficial transcripts
    # - acceptance_letter        : College acceptance letter
    # - enrollment_verification  : Enrollment verification document
    # - fafsa_sar                : FAFSA Student Aid Report
    # - financial_aid_letter     : Financial aid award letter
    # - tribal_enrollment        : Tribal enrollment verification
    # - recommendation_letter    : Letters of recommendation
    # - essay                    : Personal essays
    # - photo_id                 : Photo identification
    # - other                    : Other supporting documents
    # - scanned_historical       : Scanned paper application (for historical imports)
  end
end
