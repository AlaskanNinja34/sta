# app/models/student_financial_tracking.rb
# Tracks individual award disbursements for each application
# Links to student via tribal_id and to application via application_key

class StudentFinancialTracking < ApplicationRecord
  # Use singular table name (matches migration)
  self.table_name = 'student_financial_tracking'

  # === ASSOCIATIONS ===
  belongs_to :student, primary_key: :tribal_id, foreign_key: :tribal_id, optional: true

  # === VALIDATIONS ===
  validates :tribal_id, presence: true
  validates :application_key, presence: true
  validates :award_year, presence: true

  # === ENUMS ===
  enum :award_type, { regular: 'regular', arpa: 'arpa', combined: 'combined' }, prefix: true
  enum :award_source, { digital_application: 'digital_application', historical_import: 'historical_import' }, prefix: true
  enum :education_level, { undergraduate: 'undergraduate', graduate: 'graduate' }, prefix: true
  enum :disbursement_status, { pending: 'pending', partial: 'partial', complete: 'complete' }, prefix: true

  # === SCOPES ===
  scope :for_year, ->(year) { where(award_year: year) }
  scope :undergraduate, -> { where(education_level: 'undergraduate') }
  scope :graduate, -> { where(education_level: 'graduate') }

  # === CALLBACKS ===
  before_save :calculate_totals
  after_save :update_student_lifetime_totals

  # === INSTANCE METHODS ===

  # Calculate total disbursed from semester disbursements
  def calculate_totals
    self.total_disbursed = [
      fall_disbursement,
      winter_disbursement,
      spring_disbursement,
      summer_disbursement
    ].compact.sum

    self.remaining_balance = (total_award_amount || 0) - total_disbursed

    # Update disbursement status based on amounts
    self.disbursement_status = if total_disbursed.zero?
                                  'pending'
                                elsif remaining_balance.positive?
                                  'partial'
                                else
                                  'complete'
                                end
  end

  # Record a disbursement for a specific semester
  def record_disbursement(semester:, amount:, date: Date.current)
    case semester.to_sym
    when :fall
      self.fall_disbursement = amount
      self.fall_disbursement_date = date
    when :winter
      self.winter_disbursement = amount
      self.winter_disbursement_date = date
    when :spring
      self.spring_disbursement = amount
      self.spring_disbursement_date = date
    when :summer
      self.summer_disbursement = amount
      self.summer_disbursement_date = date
    end
    save!
  end

  private

  def update_student_lifetime_totals
    student&.recalculate_lifetime_totals!
  end
end
