# db/migrate/20251231000006_create_historical_applications.rb
# Phase 1: Create historical applications table
# For manual import of paper records with HIST-YYYY-NNN application keys
# Auto-creates student_financial_tracking records when entries are added

class CreateHistoricalApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :historical_applications do |t|
      # === LINKING FIELDS ===
      t.string :application_key, null: false     # "HIST-YYYY-NNN" format
      t.string :tribal_id, null: false           # Links to students table

      # === APPLICATION DETAILS ===
      t.integer :application_year, null: false   # Year of original application
      t.string :school_name                      # School attended
      t.string :education_level                  # 'undergraduate', 'graduate'

      # === FINANCIAL INFORMATION ===
      t.decimal :amount_requested, precision: 10, scale: 2
      t.decimal :amount_awarded, precision: 10, scale: 2    # Total amount earned/awarded
      t.string :award_type                       # 'regular', 'arpa', 'combined'

      # === ENTRY METADATA ===
      t.date :entry_date                         # When this record was entered
      t.string :entered_by_staff_id              # Staff who entered the record
      t.string :original_reference               # Any reference number from paper records

      # === NOTES ===
      t.text :notes                              # General notes about the historical application

      t.timestamps
    end

    # === INDEXES ===
    add_index :historical_applications, :application_key, unique: true
    add_index :historical_applications, :tribal_id
    add_index :historical_applications, :application_year
    add_index :historical_applications, [:tribal_id, :application_year]

    # NOTE: When a historical_application is created, the model should:
    # 1. Auto-generate application_key as "HIST-{application_year}-{sequence}"
    # 2. Auto-create a student_financial_tracking record
    # 3. Update the student's lifetime totals (total_undergrad_awarded or total_grad_awarded)
  end
end
