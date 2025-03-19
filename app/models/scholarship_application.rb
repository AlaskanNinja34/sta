# app/models/scholarship_application.rb

class ScholarshipApplication < ApplicationRecord
  # Add validations here
  validates :student_contribution, 
            :parent_contribution,
            :spouse_contribution,
            :native_corporation_grant_1,
            :native_corporation_grant_2,
            :anb_ans_grant,
            :pell_grant,
            :tuition_exemption,
            :college_work_study,
            :college_scholarship,
            :alaska_student_loan,
            :stafford_loan,
            :alaska_supplemental_loan,
            :alaska_family_education_loan,
            :supplemental_educational_opportunity_grant,
            :parent_plus_loan,
            :government_aid,
            :veterans_assistance,
            :other_resources_1,
            :other_resources_2,
            :books_supplies,
            :local_transportation,
            :other_expenses_1,
            :other_expenses_2,
            :total_resources,
            :total_expenses,
            :remaining_unmet_need,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
