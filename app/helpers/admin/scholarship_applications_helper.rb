module Admin::ScholarshipApplicationsHelper
  # Ordered list of [group_label, column_keys]
  COLUMN_GROUPS = [
    ["C", %w[first_name class_standing]],
    ["", %w[email_address student_id]],
    ["STUDENT REQUIREMENTS", %w[sta_enroll transcript_overall acceptance_letter budget_period fna_total_cost fafsa]],
    ["GPA", %w[gpa]],
    ["SCHOOL AND MAJOR/AREA OF STUDY", %w[field_of_study college_name]],
    ["", %w[vendor_id]],
    ["COMMITTEE ACTION INFORMATION", %w[committee_action amount_awarded term]],
    ["ARPA Higher Education Scholarship", %w[arpa_application_page arpa_amount_awarded]],
    ["DISTRIBUTION SCHEDULE: Higher Education CODE:", %w[distribution_he_fall_2023 distribution_he_spring_2022_2023 distribution_he_summer_2024 distribution_he_summer_2023]],
    ["DISTRIBUTION SCHEDULE: ARPA Higher Education CODE:", %w[distribution_arpa_fall_2022 distribution_arpa_spring_2022_2023 distribution_arpa_spring_2023 distribution_arpa_summer_2023]],
    ["", %w[ties_out_year_payments]],
    ["TRANSCRIPT SUBMISSION", %w[transcript_fall_term transcript_winter_term transcript_spring_term transcript_summer_term]],
    ["", %w[internal_notes]]
  ]

  # Returns an ordered array of { label:, colspan: } for visible_columns
  def grouped_headers_for(visible_columns)
    COLUMN_GROUPS.map do |label, cols|
      intersect = cols & visible_columns
      next if intersect.empty?
      { label: label, colspan: intersect.size }
    end.compact
  end
end
