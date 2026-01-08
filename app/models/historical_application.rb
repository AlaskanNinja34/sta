# app/models/historical_application.rb
# Represents a paper scholarship application imported by staff
# Uses HIST-YYYY-NNN format for application_key

class HistoricalApplication < ApplicationRecord
  # === ASSOCIATIONS ===
  belongs_to :student, primary_key: :tribal_id, foreign_key: :tribal_id, optional: true
  has_many :application_files, primary_key: :application_key, foreign_key: :application_key, dependent: :destroy

  # === CALLBACKS ===
  before_validation :normalize_amounts
  before_create :generate_application_key
  after_create :create_financial_tracking_records
  after_create :update_student_lifetime_totals

  # === VALIDATIONS ===
  validates :tribal_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :application_year, presence: true
  validates :application_key, uniqueness: true, allow_nil: true

  # === ENUMS ===
  enum :award_type, { regular: 'regular', arpa: 'arpa', combined: 'combined' }, prefix: true
  enum :education_level, { undergraduate: 'undergraduate', graduate: 'graduate' }, prefix: true

  # === SCOPES ===
  scope :for_year, ->(year) { where(application_year: year) }
  scope :undergraduate, -> { where(education_level: 'undergraduate') }
  scope :graduate, -> { where(education_level: 'graduate') }

  # === INSTANCE METHODS ===

  # Display name combining year and school
  def display_name
    "#{application_year} - #{school_name || 'Unknown School'}"
  end

  # Get the best available name for this student
  # Priority: 1) Most recent digital application, 2) Most recent historical application, 3) This record
  def display_student_name
    # First check for a linked student with digital applications
    if student.present?
      # Check for most recent digital application
      recent_app = Application.where(tribal_id: tribal_id).order(created_at: :desc).first
      if recent_app.present? && recent_app.first_name.present?
        return [recent_app.first_name, recent_app.last_name].compact.join(' ')
      end

      # Fall back to student profile name
      return student.full_name if student.first_name.present?
    end

    # Check for most recent historical application (by year)
    recent_hist = HistoricalApplication.where(tribal_id: tribal_id)
                                        .where.not(first_name: nil)
                                        .order(application_year: :desc)
                                        .first
    if recent_hist.present? && recent_hist.first_name.present?
      return [recent_hist.first_name, recent_hist.last_name].compact.join(' ')
    end

    # Fall back to this record's name
    [first_name, last_name].compact.join(' ').presence || 'Unknown'
  end

  private

  # Normalize amounts based on award type
  def normalize_amounts
    case award_type
    when 'regular'
      # Regular only: regular_amount = amount_awarded, no arpa
      self.regular_amount = amount_awarded if regular_amount.blank? && amount_awarded.present?
      self.arpa_amount = nil
    when 'arpa'
      # ARPA only: arpa_amount = amount_awarded, no regular
      self.arpa_amount = amount_awarded if arpa_amount.blank? && amount_awarded.present?
      self.regular_amount = nil
    when 'combined'
      # Combined: both amounts should be set, amount_awarded = sum
      if regular_amount.present? && arpa_amount.present?
        self.amount_awarded = (regular_amount || 0) + (arpa_amount || 0)
      end
    end
  end

  # Generate unique application key in HIST-YYYY-NNN format
  def generate_application_key
    return if application_key.present?

    year = application_year
    # Find the highest sequence number for this year
    last_app = HistoricalApplication.where(application_year: year)
                                     .where.not(application_key: nil)
                                     .order(application_key: :desc)
                                     .first

    if last_app&.application_key
      # Extract sequence number from last key (e.g., "HIST-2020-015" -> 15)
      last_seq = last_app.application_key.split('-').last.to_i
      next_seq = last_seq + 1
    else
      next_seq = 1
    end

    self.application_key = "HIST-#{year}-#{next_seq.to_s.rjust(3, '0')}"
  end

  # Auto-create financial tracking record(s) when historical app is created
  # For combined awards, creates TWO records: one regular and one ARPA
  def create_financial_tracking_records
    return unless amount_awarded.present? && amount_awarded.positive?

    case award_type
    when 'regular'
      create_single_financial_record('regular', regular_amount || amount_awarded)
    when 'arpa'
      create_single_financial_record('arpa', arpa_amount || amount_awarded)
    when 'combined'
      # Create separate records for regular and ARPA portions
      create_single_financial_record('regular', regular_amount) if regular_amount.present? && regular_amount.positive?
      create_single_financial_record('arpa', arpa_amount) if arpa_amount.present? && arpa_amount.positive?
    end
  end

  def create_single_financial_record(type, amount)
    return unless amount.present? && amount.positive?

    StudentFinancialTracking.create!(
      tribal_id: tribal_id,
      application_key: application_key,
      award_year: application_year,
      award_type: type,
      award_source: 'historical_import',
      education_level: education_level || 'undergraduate',
      total_award_amount: amount,
      disbursement_status: 'complete',  # Historical records are already disbursed
      total_disbursed: amount,
      remaining_balance: 0,
      notes: "Imported from historical paper records (#{type.upcase}). #{notes}"
    )
  end

  # Update student's lifetime totals after import
  def update_student_lifetime_totals
    student&.recalculate_lifetime_totals!
  end
end
