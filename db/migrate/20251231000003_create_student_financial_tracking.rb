# db/migrate/20251231000003_create_student_financial_tracking.rb
# Phase 1: Create student financial tracking table
# Links to students via tribal_id and to applications via application_key
# Tracks individual award disbursements and contributes to lifetime totals

class CreateStudentFinancialTracking < ActiveRecord::Migration[8.0]
  def change
    create_table :student_financial_tracking do |t|
      # === LINKING FIELDS ===
      t.string :tribal_id, null: false           # Links to students table (person)
      t.string :application_key, null: false     # Links to applications table (YYYY-NNN or HIST-YYYY-NNN)

      # === AWARD INFORMATION ===
      t.integer :award_year, null: false         # Year of award (e.g., 2025)
      t.string :award_type                       # 'regular', 'arpa', 'combined'
      t.string :award_source                     # 'digital_application', 'historical_import'
      t.string :education_level                  # 'undergraduate', 'graduate'

      # === AMOUNTS ===
      t.decimal :amount_requested, precision: 10, scale: 2
      t.decimal :total_award_amount, precision: 10, scale: 2   # Total approved amount
      t.decimal :he_amount, precision: 10, scale: 2            # Regular HE scholarship amount
      t.decimal :arpa_amount, precision: 10, scale: 2          # ARPA funding amount

      # === SEMESTER DISBURSEMENTS ===
      t.decimal :fall_disbursement, precision: 10, scale: 2
      t.date :fall_disbursement_date
      t.decimal :winter_disbursement, precision: 10, scale: 2
      t.date :winter_disbursement_date
      t.decimal :spring_disbursement, precision: 10, scale: 2
      t.date :spring_disbursement_date
      t.decimal :summer_disbursement, precision: 10, scale: 2
      t.date :summer_disbursement_date

      # === STATUS ===
      t.string :disbursement_status              # 'pending', 'partial', 'complete'
      t.decimal :total_disbursed, precision: 10, scale: 2
      t.decimal :remaining_balance, precision: 10, scale: 2

      # === AUDIT FIELDS ===
      t.text :notes
      t.string :created_by                       # Staff who created record
      t.string :last_modified_by                 # Staff who last modified

      t.timestamps
    end

    # === INDEXES ===
    add_index :student_financial_tracking, :tribal_id
    add_index :student_financial_tracking, :application_key
    add_index :student_financial_tracking, :award_year
    add_index :student_financial_tracking, [:tribal_id, :award_year]
    add_index :student_financial_tracking, [:tribal_id, :education_level]
  end
end
