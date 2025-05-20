class AddAdditionalFieldsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :scholarship_applications, :release_signature, :string
    add_column :scholarship_applications, :release_date, :date
    add_column :scholarship_applications, :enrollment_last_name, :string
    add_column :scholarship_applications, :enrollment_first_name, :string
    add_column :scholarship_applications, :enrollment_middle_name, :string
    add_column :scholarship_applications, :enrollment_date_of_birth, :date
    add_column :scholarship_applications, :enrollment_sex, :string
    add_column :scholarship_applications, :enrollment_phone, :string
    add_column :scholarship_applications, :enrollment_place_of_birth, :string
    add_column :scholarship_applications, :enrollment_mailing_city, :string
    add_column :scholarship_applications, :enrollment_mailing_state, :string
    add_column :scholarship_applications, :enrollment_mailing_zip, :string
    add_column :scholarship_applications, :financial_student_name, :string
    add_column :scholarship_applications, :financial_student_id, :string
    add_column :scholarship_applications, :financial_aid_status, :string
    add_column :scholarship_applications, :budget_period, :string
    add_column :scholarship_applications, :student_resources, :text
    add_column :scholarship_applications, :photo_release_signature, :string
    add_column :scholarship_applications, :photo_release_date, :date
    add_column :scholarship_applications, :parental_release_signature, :string
    add_column :scholarship_applications, :parental_release_date, :date
    add_column :scholarship_applications, :arpa_student_name, :string
    add_column :scholarship_applications, :arpa_authorization, :boolean
    add_column :scholarship_applications, :arpa_signature, :string
    add_column :scholarship_applications, :arpa_date, :date
  end
end
