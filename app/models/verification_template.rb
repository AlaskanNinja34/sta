# app/models/verification_template.rb
# Manages the verification workflow for an application
# Links to application via application_key

class VerificationTemplate < ApplicationRecord
  # === DEFAULT CHECKLIST ITEMS ===
  DEFAULT_CHECKLIST = {
    'tribal_id_verified' => { 'checked' => false, 'label' => 'Tribal ID Verified', 'required' => true },
    'transcript_received' => { 'checked' => false, 'label' => 'Transcript Received', 'required' => true },
    'transcript_reviewed' => { 'checked' => false, 'label' => 'Transcript Reviewed', 'required' => true },
    'fafsa_reviewed' => { 'checked' => false, 'label' => 'FAFSA Reviewed', 'required' => true },
    'enrollment_verified' => { 'checked' => false, 'label' => 'Enrollment Verified', 'required' => true },
    'gpa_requirements_met' => { 'checked' => false, 'label' => 'GPA Requirements Met', 'required' => true },
    'course_load_verified' => { 'checked' => false, 'label' => 'Course Load Verified', 'required' => true },
    'fna_calculated' => { 'checked' => false, 'label' => 'FNA Calculated', 'required' => true },
    'fna_reviewed' => { 'checked' => false, 'label' => 'FNA Reviewed', 'required' => true },
    'award_recommended' => { 'checked' => false, 'label' => 'Award Amount Recommended', 'required' => true }
  }.freeze

  # === ASSOCIATIONS ===
  # Link to application via application_key (not a traditional foreign key)
  belongs_to :application, primary_key: :application_key, foreign_key: :application_key, optional: true

  # === VALIDATIONS ===
  validates :application_key, presence: true, uniqueness: true
  validates :verification_status, inclusion: { in: %w[not_started in_progress completed] }

  # === SCOPES ===
  scope :not_started, -> { where(verification_status: 'not_started') }
  scope :in_progress, -> { where(verification_status: 'in_progress') }
  scope :completed, -> { where(verification_status: 'completed') }
  scope :current, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  # === CALLBACKS ===
  after_initialize :initialize_checklist, if: :new_record?
  before_save :update_progress

  # === INSTANCE METHODS ===

  # Initialize checklist with default items
  def initialize_checklist
    self.checklist_data ||= DEFAULT_CHECKLIST.deep_dup
    self.items_total = checklist_data.size
  end

  # Update a checklist item
  def update_item(item_key, checked:, verified_by: nil, notes: nil)
    return false unless checklist_data.key?(item_key)

    checklist_data[item_key]['checked'] = checked
    checklist_data[item_key]['verified_by'] = verified_by if checked
    checklist_data[item_key]['verified_at'] = Time.current.iso8601 if checked
    checklist_data[item_key]['notes'] = notes if notes.present?

    # Start verification if this is the first item checked
    if verification_status == 'not_started' && checked
      self.verification_status = 'in_progress'
      self.verification_started_at = Time.current
    end

    save!
  end

  # Get all checklist items with their status
  def checklist_items
    checklist_data.map do |key, data|
      {
        key: key,
        label: data['label'],
        checked: data['checked'],
        required: data['required'],
        verified_by: data['verified_by'],
        verified_at: data['verified_at'],
        notes: data['notes']
      }
    end
  end

  # Check if all required items are complete
  def all_required_complete?
    checklist_data.all? do |_key, data|
      !data['required'] || data['checked']
    end
  end

  # Mark verification as complete
  def complete!(completed_by:)
    return false unless all_required_complete?

    update!(
      verification_status: 'completed',
      verification_completed_at: Time.current,
      completed_by: completed_by,
      completion_percentage: 100.0
    )
  end

  # Archive the verification template (after 10-month lifecycle)
  def archive!
    update!(
      archived: true,
      archived_at: Time.current
    )
  end

  # Unarchive if needed
  def unarchive!
    update!(
      archived: false,
      archived_at: nil
    )
  end

  private

  # Update progress percentage
  def update_progress
    return if checklist_data.blank?

    completed_count = checklist_data.count { |_k, v| v['checked'] }
    self.items_completed = completed_count
    self.items_total = checklist_data.size
    self.completion_percentage = (completed_count.to_f / checklist_data.size * 100).round(2)
  end
end
