# app/models/student.rb
# Represents a tribal member who can apply for scholarships
# Primary identifier: tribal_id (externally assigned by tribe enrollment office)

class Student < ApplicationRecord
  # === ASSOCIATIONS ===
  # Link via tribal_id (not id) since tribal_id is the meaningful identifier
  has_many :applications, primary_key: :tribal_id, foreign_key: :tribal_id, dependent: :restrict_with_error
  has_many :historical_applications, primary_key: :tribal_id, foreign_key: :tribal_id, dependent: :restrict_with_error
  has_many :student_financial_trackings, primary_key: :tribal_id, foreign_key: :tribal_id, dependent: :restrict_with_error

  # === VALIDATIONS ===
  validates :tribal_id, presence: true, uniqueness: true

  # === LIFETIME AWARD LIMITS ===
  # Total lifetime cap is $24,000
  # Undergrad can use up to $15,000
  # Graduate can use up to $9,000 PLUS any unused undergrad funds
  TOTAL_LIFETIME_LIMIT = 24_000.00
  UNDERGRAD_ALLOCATION = 15_000.00
  GRAD_BASE_ALLOCATION = 9_000.00
  WARNING_THRESHOLD_PERCENTAGE = 0.80  # 80% of limit triggers warning

  # === SCOPES ===
  scope :approaching_undergrad_limit, -> { where(close_to_undergrad_limit: true) }
  scope :approaching_grad_limit, -> { where(close_to_grad_limit: true) }
  scope :approaching_lifetime_limit, -> { where('(COALESCE(total_undergrad_awarded, 0) + COALESCE(total_grad_awarded, 0)) >= ?', TOTAL_LIFETIME_LIMIT * WARNING_THRESHOLD_PERCENTAGE) }

  # === INSTANCE METHODS ===

  # Alias methods for backward compatibility with views
  def lifetime_undergrad_total
    total_undergrad_awarded || 0
  end

  def lifetime_grad_total
    total_grad_awarded || 0
  end

  # Total lifetime amount awarded (undergrad + grad)
  def lifetime_total_awarded
    lifetime_undergrad_total + lifetime_grad_total
  end

  # Full name for display
  def full_name
    [first_name, middle_initial, last_name].compact.join(' ')
  end

  # Calculate remaining undergraduate award eligibility
  # Undergrad is capped at $15,000 and also by total lifetime limit
  def remaining_undergrad_eligibility
    undergrad_cap_remaining = UNDERGRAD_ALLOCATION - lifetime_undergrad_total
    lifetime_cap_remaining = TOTAL_LIFETIME_LIMIT - lifetime_total_awarded
    [undergrad_cap_remaining, lifetime_cap_remaining].min.clamp(0, Float::INFINITY)
  end

  # Calculate remaining graduate award eligibility
  # Graduate gets $9,000 base + any unused undergrad allocation
  # Also capped by total lifetime limit
  def remaining_grad_eligibility
    unused_undergrad = [UNDERGRAD_ALLOCATION - lifetime_undergrad_total, 0].max
    grad_allocation = GRAD_BASE_ALLOCATION + unused_undergrad
    grad_cap_remaining = grad_allocation - lifetime_grad_total
    lifetime_cap_remaining = TOTAL_LIFETIME_LIMIT - lifetime_total_awarded
    [grad_cap_remaining, lifetime_cap_remaining].min.clamp(0, Float::INFINITY)
  end

  # Total remaining eligibility (remaining from $24,000 lifetime cap)
  def remaining_lifetime_eligibility
    (TOTAL_LIFETIME_LIMIT - lifetime_total_awarded).clamp(0, Float::INFINITY)
  end

  # Effective graduate allocation (base $9k + unused undergrad)
  def effective_grad_allocation
    unused_undergrad = [UNDERGRAD_ALLOCATION - lifetime_undergrad_total, 0].max
    GRAD_BASE_ALLOCATION + unused_undergrad
  end

  # Check if approaching undergraduate limit
  def approaching_undergrad_limit?
    return false if lifetime_undergrad_total.zero?
    lifetime_undergrad_total >= (UNDERGRAD_ALLOCATION * WARNING_THRESHOLD_PERCENTAGE)
  end

  # Check if approaching graduate limit (using effective allocation)
  def approaching_grad_limit?
    return false if lifetime_grad_total.zero?
    lifetime_grad_total >= (effective_grad_allocation * WARNING_THRESHOLD_PERCENTAGE)
  end

  # Check if approaching total lifetime limit
  def approaching_lifetime_limit?
    lifetime_total_awarded >= (TOTAL_LIFETIME_LIMIT * WARNING_THRESHOLD_PERCENTAGE)
  end

  # Update limit warning flags (call after any award changes)
  def update_limit_flags!
    update!(
      close_to_undergrad_limit: approaching_undergrad_limit?,
      close_to_grad_limit: approaching_grad_limit?
    )
  end

  # Recalculate lifetime totals from financial tracking records
  # NOTE: ARPA awards are tracked but do NOT count toward lifetime limits
  def recalculate_lifetime_totals!
    # Only count 'regular' awards toward lifetime totals
    # ARPA and combined awards are tracked separately
    undergrad_total = student_financial_trackings
      .where(education_level: 'undergraduate')
      .where(award_type: 'regular')
      .sum(:total_award_amount)

    grad_total = student_financial_trackings
      .where(education_level: 'graduate')
      .where(award_type: 'regular')
      .sum(:total_award_amount)

    update!(
      total_undergrad_awarded: undergrad_total,
      total_grad_awarded: grad_total
    )
    update_limit_flags!
  end

  # Get total ARPA awards (tracked separately, doesn't count toward limits)
  def total_arpa_awarded
    student_financial_trackings.where(award_type: 'arpa').sum(:total_award_amount)
  end

  # Get all applications (both digital and historical) for this student
  def all_applications
    {
      digital: applications.order(application_year: :desc),
      historical: historical_applications.order(application_year: :desc)
    }
  end
end
