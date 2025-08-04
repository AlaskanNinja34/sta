# db/migrate/20250717_add_dashboard_columns_to_scholarship_applications.rb
class AddDashboardColumnsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    # academic summary
    add_column :scholarship_applications, :gpa,                         :decimal, precision: 4,  scale: 2

    # student‐requirement flags
    add_column :scholarship_applications, :sta_enroll,                 :boolean, default: false
    add_column :scholarship_applications, :transcript_overall,         :boolean, default: false
    add_column :scholarship_applications, :acceptance_letter,          :boolean, default: false
    add_column :scholarship_applications, :fafsa,                      :boolean, default: false

    # vendor/ID
    add_column :scholarship_applications, :vendor_id,                  :string

    # committee action
    add_column :scholarship_applications, :committee_action,           :string
    add_column :scholarship_applications, :amount_awarded,             :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :term,                       :string

    # ARPA scholarship
    add_column :scholarship_applications, :arpa_application_page,      :string
    add_column :scholarship_applications, :arpa_amount_awarded,        :decimal, precision: 10, scale: 2

    # distribution schedules — HE Code
    add_column :scholarship_applications, :distribution_he_fall_2023,                   :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_he_spring_2022_2023,           :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_he_summer_2024,                 :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_he_summer_2023,                 :decimal, precision: 10, scale: 2

    # distribution schedules — ARPA Code
    add_column :scholarship_applications, :distribution_arpa_fall_2022,                :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_arpa_spring_2022_2023,        :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_arpa_spring_2023,              :decimal, precision: 10, scale: 2
    add_column :scholarship_applications, :distribution_arpa_summer_2023,              :decimal, precision: 10, scale: 2

    # reconciliation
    add_column :scholarship_applications, :ties_out_year_payments,      :decimal, precision: 10, scale: 2

    # transcript submission by term
    add_column :scholarship_applications, :transcript_fall_term,       :boolean, default: false
    add_column :scholarship_applications, :transcript_winter_term,     :boolean, default: false
    add_column :scholarship_applications, :transcript_spring_term,     :boolean, default: false
    add_column :scholarship_applications, :transcript_summer_term,     :boolean, default: false
  end
end
