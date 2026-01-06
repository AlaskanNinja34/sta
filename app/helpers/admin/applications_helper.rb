# app/helpers/admin/applications_helper.rb
# Helper methods for admin application views

module Admin::ApplicationsHelper
  # Ordered list of [group_label, column_keys]
  COLUMN_GROUPS = [
    ["C", %w[first_name class_standing]],
    ["", %w[email_address school_issued_student_id]],
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
  ].freeze

  # Returns an ordered array of { label:, colspan: } for visible_columns
  def grouped_headers_for(visible_columns)
    COLUMN_GROUPS.map do |label, cols|
      intersect = cols & visible_columns
      next if intersect.empty?

      { label: label, colspan: intersect.size }
    end.compact
  end

  # Returns a hash mapping section titles to attribute-value pairs
  def sectioned_application_attributes(application)
    attrs = application.attributes.symbolize_keys.except(:id, :created_at, :updated_at)

    # Static field lists for initial sections
    sections = {
      "Applicant Information" => %i[
        last_name first_name middle_initial previous_maiden_name school_issued_student_id
        date_of_birth place_of_birth marital_status number_of_dependents
        tribe_enrolled previous_scholarship previous_scholarship_year
        preferred_contact email_address permanent_phone school_phone
        tribal_id application_key
      ],
      "Address Information" => %i[
        mailing_address_permanent city state zip_code mailing_address_school
        city_school state_school zip_code_school
      ],
      "Education History" => %i[
        education_earned school_name school_city_state school_month_year_earned
        previous_college1_name previous_college1_start_date previous_college1_end_date previous_college1_credits
        previous_college1_degree previous_college2_name previous_college2_start_date previous_college2_end_date
        previous_college2_credits previous_college2_degree previous_college3_name
        previous_college3_start_date previous_college3_end_date previous_college3_credits previous_college3_degree
      ],
      "Education Plan" => %i[
        college_name college_financial_aid_office college_phone college_fax
        college_financial_aid_mailing_address college_city college_state
        college_zip_code college_term_type
        deadline_fee_payments_fall deadline_fee_payments_winter
        deadline_fee_payments_spring deadline_fee_payments_summer
        credits_taking_fall credits_taking_winter
        credits_taking_spring credits_taking_summer
        current_degree_program expected_graduation_date class_standing
        field_of_study minor
      ],
      "Educational Goals" => %i[
        educational_goals
        certify_information
        signature
        date
        certify_not_defaulting
      ]
    }

    # Dynamic sections using prefixes
    dynamic_sections = {
      "Budget Forecast" => /^(
        tuition|fees|room_board|books|transportation|personal_expenses|
        other_expense|student_contribution|parent_contribution|spouse_contribution|
        native_corp_grant|anb_ans_grant|pell_grant|tuition_exemption|
        college_work_study|college_scholarship|alaska_student_loan|stafford_loan|
        alaska_supplemental_loan|alaska_family_education_loan|seog_grant|
        parent_plus_loan|government_assistance|veterans_assistance|
        other_resource|total_resources|total_expenses|total_expenses_calc|
        minus_total_resources|unmet_need|cover_remaining_need|amount_requested
      )/x,
      "Release of Information" => /^release_/,
      "Enrollment Verification" => /^enrollment_/,
      "Financial Needs Analysis" => /^(financial_|fna_|budget_period_|fao_|student_resources)/,
      "Photo Release Form" => /^photo_release_/,
      "Parental/Spousal Release Form (Optional)" => /^parental_release_/,
      "ARPA Higher Education Scholarship" => /^arpa_/
    }

    dynamic_sections.each do |title, regex|
      sections[title] = attrs.keys.grep(regex)
    end

    sections.transform_values { |keys| attrs.slice(*keys) }
  end
end
