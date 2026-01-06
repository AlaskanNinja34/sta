# app/models/application.rb
# Represents a scholarship application submitted by a student
# Linked to student via tribal_id, identified by application_key (YYYY-NNN format)

class Application < ApplicationRecord
  # === ASSOCIATIONS ===
  belongs_to :student, primary_key: :tribal_id, foreign_key: :tribal_id, optional: true
  has_one :verification_template, primary_key: :application_key, foreign_key: :application_key, dependent: :destroy
  has_many :application_files, primary_key: :application_key, foreign_key: :application_key, dependent: :destroy
  has_many :student_financial_trackings, primary_key: :application_key, foreign_key: :application_key

  # File attachments (using Active Storage)
  has_many_attached :uploaded_files

  # === CALLBACKS ===
  before_validation :set_application_year, on: :create
  before_create :generate_application_key
  after_create :create_verification_template

  # === VALIDATIONS ===
  validates :tribal_id, presence: true
  validates :application_key, uniqueness: true, allow_nil: true
  validates :application_year, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true

  # === ENUMS ===
  enum :application_type, { digital: 'digital', historical_import: 'historical_import' }, default: :digital

  # === STATUS VALUES ===
  STATUSES = %w[submitted under_review approved rejected more_info_needed].freeze
  BOARD_STATUSES = %w[pending approved denied].freeze

  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validates :board_status, inclusion: { in: BOARD_STATUSES }, allow_nil: true

  # === SCOPES ===
  scope :submitted, -> { where(status: 'submitted') }
  scope :under_review, -> { where(status: 'under_review') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :for_year, ->(year) { where(application_year: year) }
  scope :current_year, -> { where(application_year: Date.current.year) }

  # === INSTANCE METHODS ===

  # Full name for display
  def full_name
    [first_name, middle_initial, last_name].compact.join(' ')
  end

  # Check if application is editable
  def editable?
    %w[submitted more_info_needed].include?(status)
  end

  # Mark as under review
  def start_review!
    update!(status: 'under_review')
  end

  # Approve application
  def approve!(award_amount: nil, arpa_amount: nil)
    update!(
      status: 'approved',
      amount_awarded: award_amount,
      arpa_amount_awarded: arpa_amount
    )
    create_financial_tracking_record if award_amount.present? || arpa_amount.present?
  end

  # Reject application
  def reject!
    update!(status: 'rejected')
  end

  # Request more information
  def request_more_info!
    update!(status: 'more_info_needed')
  end

  private

  # Set application year from current date if not provided
  def set_application_year
    self.application_year ||= Date.current.year
  end

  # Generate unique application key in YYYY-NNN format
  def generate_application_key
    return if application_key.present?

    year = application_year
    # Find the highest sequence number for this year
    last_app = Application.where(application_year: year)
                          .where.not(application_key: nil)
                          .order(application_key: :desc)
                          .first

    if last_app&.application_key
      # Extract sequence number from last key (e.g., "2025-042" -> 42)
      last_seq = last_app.application_key.split('-').last.to_i
      next_seq = last_seq + 1
    else
      next_seq = 1
    end

    self.application_key = "#{year}-#{next_seq.to_s.rjust(3, '0')}"
  end

  # Create associated verification template
  def create_verification_template
    VerificationTemplate.create!(
      application_key: application_key,
      verification_status: 'not_started'
    )
  end

  # Create financial tracking record when approved with award amount
  def create_financial_tracking_record
    StudentFinancialTracking.create!(
      tribal_id: tribal_id,
      application_key: application_key,
      award_year: application_year,
      award_type: determine_award_type,
      award_source: 'digital_application',
      education_level: determine_education_level,
      amount_requested: amount_requested,
      total_award_amount: (amount_awarded || 0) + (arpa_amount_awarded || 0),
      he_amount: amount_awarded,
      arpa_amount: arpa_amount_awarded,
      disbursement_status: 'pending'
    )

    # Update student lifetime totals
    student&.recalculate_lifetime_totals!
  end

  def determine_award_type
    if amount_awarded.present? && arpa_amount_awarded.present?
      'combined'
    elsif arpa_amount_awarded.present?
      'arpa'
    else
      'regular'
    end
  end

  def determine_education_level
    # Determine from degree program or class standing
    graduate_indicators = ['graduate', 'masters', 'doctoral', 'phd', 'mba']
    program = current_degree_program&.downcase || ''

    graduate_indicators.any? { |ind| program.include?(ind) } ? 'graduate' : 'undergraduate'
  end
end
