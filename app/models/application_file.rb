# app/models/application_file.rb
# Represents a file attached to an application
# Links to application via application_key (works with both digital and historical apps)

class ApplicationFile < ApplicationRecord
  # === FILE CATEGORIES ===
  CATEGORIES = %w[
    transcript_official
    transcript_unofficial
    acceptance_letter
    enrollment_verification
    fafsa_sar
    financial_aid_letter
    tribal_enrollment
    recommendation_letter
    essay
    photo_id
    scanned_historical
    other
  ].freeze

  # === VALIDATIONS ===
  validates :application_key, presence: true
  validates :file_category, presence: true, inclusion: { in: CATEGORIES }

  # === SCOPES ===
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }
  scope :required, -> { where(required: true) }
  scope :by_category, ->(cat) { where(file_category: cat) }

  # === INSTANCE METHODS ===

  # Mark file as verified by staff
  def verify!(staff_identifier)
    update!(
      verified: true,
      verified_at: Time.current,
      verified_by: staff_identifier
    )
  end

  # Unverify file
  def unverify!
    update!(
      verified: false,
      verified_at: nil,
      verified_by: nil
    )
  end

  # Human-readable category name
  def category_display_name
    file_category.to_s.titleize.gsub('Fafsa', 'FAFSA').gsub('Sar', 'SAR')
  end

  # Check if this is a transcript file
  def transcript?
    file_category.to_s.start_with?('transcript')
  end

  # File size in human-readable format
  def file_size_display
    return 'Unknown' if file_size.nil?

    if file_size < 1024
      "#{file_size} B"
    elsif file_size < 1024 * 1024
      "#{(file_size / 1024.0).round(1)} KB"
    else
      "#{(file_size / (1024.0 * 1024)).round(1)} MB"
    end
  end
end
