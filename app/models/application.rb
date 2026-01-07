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

  # --- Required Fields (Core Identity) ---
  validates :tribal_id, presence: true
  validates :application_key, uniqueness: true, allow_nil: true
  validates :application_year, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true
  validates :date_of_birth, presence: true

  # --- Required Fields (Education - for submission) ---
  validates :college_name, presence: true, on: :submission
  validates :current_degree_program, presence: true, on: :submission
  validates :class_standing, presence: true, on: :submission
  validates :field_of_study, presence: true, on: :submission
  validates :educational_goals, presence: true, on: :submission

  # --- Required Fields (Financial - for submission) ---
  validates :amount_requested, presence: true, on: :submission

  # --- Required Fields (Certifications - for submission) ---
  validates :certify_information, acceptance: { accept: true, message: 'You must certify that the information is accurate' }, on: :submission

  # --- Format Validations ---
  validates :email_address, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: 'must be a valid email address'
  }, allow_blank: true

  validates :permanent_phone, format: {
    with: /\A[\d\s\-\(\)\+\.]+\z/,
    message: 'must be a valid phone number'
  }, allow_blank: true

  validates :school_phone, format: {
    with: /\A[\d\s\-\(\)\+\.]+\z/,
    message: 'must be a valid phone number'
  }, allow_blank: true

  # ZIP codes - no strict format, just basic length check
  validates :zip_code, length: { maximum: 20 }, allow_blank: true
  validates :zip_code_school, length: { maximum: 20 }, allow_blank: true
  validates :college_zip_code, length: { maximum: 20 }, allow_blank: true

  # --- Length Validations ---
  validates :middle_initial, length: { maximum: 1 }, allow_blank: true
  # State fields accept full state names (e.g., "Alaska") or abbreviations (e.g., "AK")
  validates :state, length: { maximum: 50 }, allow_blank: true
  validates :state_school, length: { maximum: 50 }, allow_blank: true
  validates :college_state, length: { maximum: 50 }, allow_blank: true
  validates :educational_goals, length: { maximum: 5000 }, allow_blank: true
  validates :internal_notes, length: { maximum: 10000 }, allow_blank: true

  # --- Numericality Validations ---
  validates :gpa, numericality: {
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 4.0,
    message: 'must be between 0.0 and 4.0'
  }, allow_nil: true

  validates :amount_requested, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 3000,
    message: 'must be between $0 and $3,000'
  }, allow_nil: true

  validates :amount_awarded, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 3000,
    message: 'must be between $0 and $3,000'
  }, allow_nil: true

  validates :arpa_amount_awarded, numericality: {
    greater_than_or_equal_to: 0,
    message: 'must be a positive amount'
  }, allow_nil: true

  validates :number_of_dependents, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    message: 'must be 0 or more'
  }, allow_nil: true

  # Credits validation (reasonable range for semester/quarter)
  validates :credits_taking_fall, :credits_taking_winter, :credits_taking_spring, :credits_taking_summer,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 30,
      message: 'must be between 0 and 30'
    }, allow_nil: true

  validates :previous_college1_credits, :previous_college2_credits, :previous_college3_credits,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      message: 'must be 0 or more'
    }, allow_nil: true

  # All monetary fields must be non-negative
  MONETARY_FIELDS = %i[
    tuition fees room_board books transportation personal_expenses
    student_contribution parent_contribution spouse_contribution
    native_corp_grant1_amount native_corp_grant2_amount anb_ans_grant
    pell_grant tuition_exemption college_work_study college_scholarship_amount
    seog_grant alaska_student_loan stafford_loan alaska_supplemental_loan
    alaska_family_education_loan parent_plus_loan government_assistance
    veterans_assistance other_resource1_amount other_resource2_amount
    other_expense1_amount other_expense2_amount total_resources total_expenses
  ].freeze

  MONETARY_FIELDS.each do |field|
    validates field, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  end

  # --- Inclusion Validations ---
  CLASS_STANDINGS = ['Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate', '5th Year Senior', 'Post-Baccalaureate'].freeze
  MARITAL_STATUSES = ['Single', 'Married', 'Divorced', 'Widowed', 'Separated', 'Domestic Partnership'].freeze
  TERM_TYPES = ['Semester', 'Quarter', 'Trimester'].freeze

  # US States and Territories (code => name)
  US_STATES = {
    'AL' => 'Alabama', 'AK' => 'Alaska', 'AZ' => 'Arizona', 'AR' => 'Arkansas',
    'CA' => 'California', 'CO' => 'Colorado', 'CT' => 'Connecticut', 'DE' => 'Delaware',
    'FL' => 'Florida', 'GA' => 'Georgia', 'HI' => 'Hawaii', 'ID' => 'Idaho',
    'IL' => 'Illinois', 'IN' => 'Indiana', 'IA' => 'Iowa', 'KS' => 'Kansas',
    'KY' => 'Kentucky', 'LA' => 'Louisiana', 'ME' => 'Maine', 'MD' => 'Maryland',
    'MA' => 'Massachusetts', 'MI' => 'Michigan', 'MN' => 'Minnesota', 'MS' => 'Mississippi',
    'MO' => 'Missouri', 'MT' => 'Montana', 'NE' => 'Nebraska', 'NV' => 'Nevada',
    'NH' => 'New Hampshire', 'NJ' => 'New Jersey', 'NM' => 'New Mexico', 'NY' => 'New York',
    'NC' => 'North Carolina', 'ND' => 'North Dakota', 'OH' => 'Ohio', 'OK' => 'Oklahoma',
    'OR' => 'Oregon', 'PA' => 'Pennsylvania', 'RI' => 'Rhode Island', 'SC' => 'South Carolina',
    'SD' => 'South Dakota', 'TN' => 'Tennessee', 'TX' => 'Texas', 'UT' => 'Utah',
    'VT' => 'Vermont', 'VA' => 'Virginia', 'WA' => 'Washington', 'WV' => 'West Virginia',
    'WI' => 'Wisconsin', 'WY' => 'Wyoming', 'DC' => 'District of Columbia',
    'PR' => 'Puerto Rico', 'VI' => 'Virgin Islands', 'GU' => 'Guam', 'AS' => 'American Samoa',
    'MP' => 'Northern Mariana Islands'
  }.freeze
  DEGREE_PROGRAMS = [
    'Certificate', 'Associate of Arts', 'Associate of Science', 'Associate of Applied Science',
    'Bachelor of Arts', 'Bachelor of Science', 'Bachelor of Business', 'Bachelor of Fine Arts',
    'Master of Arts', 'Master of Science', 'Master of Business Administration', 'Master of Social Work',
    'Master of Education', 'Doctoral', 'PhD', 'Other'
  ].freeze

  validates :class_standing, inclusion: { in: CLASS_STANDINGS, message: 'is not a valid class standing' }, allow_blank: true
  validates :marital_status, inclusion: { in: MARITAL_STATUSES, message: 'is not a valid marital status' }, allow_blank: true
  validates :college_term_type, inclusion: { in: TERM_TYPES, message: 'is not a valid term type' }, allow_blank: true

  # --- Date Validations ---
  validate :date_of_birth_is_reasonable, if: -> { date_of_birth.present? }
  validate :expected_graduation_is_future, if: -> { expected_graduation_date.present? }

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

  # --- Custom Date Validations ---

  def date_of_birth_is_reasonable
    if date_of_birth > Date.current
      errors.add(:date_of_birth, 'cannot be in the future')
    end
  end

  def expected_graduation_is_future
    if expected_graduation_date < Date.current
      errors.add(:expected_graduation_date, 'must be a future date')
    end
  end
end
