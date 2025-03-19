class AddBudgetFieldsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :scholarship_applications, :student_contribution, :decimal
    add_column :scholarship_applications, :parent_contribution, :decimal
    add_column :scholarship_applications, :spouse_contribution, :decimal
    add_column :scholarship_applications, :native_corporation_grant_1, :decimal
    add_column :scholarship_applications, :native_corporation_grant_2, :decimal
    add_column :scholarship_applications, :anb_ans_grant, :decimal
    add_column :scholarship_applications, :pell_grant, :decimal
    add_column :scholarship_applications, :tuition_exemption, :decimal
    add_column :scholarship_applications, :college_work_study, :decimal
    add_column :scholarship_applications, :college_scholarship, :decimal
    add_column :scholarship_applications, :alaska_student_loan, :decimal
    add_column :scholarship_applications, :stafford_loan, :decimal
    add_column :scholarship_applications, :alaska_supplemental_loan, :decimal
    add_column :scholarship_applications, :alaska_family_education_loan, :decimal
    add_column :scholarship_applications, :supplemental_educational_opportunity_grant, :decimal
    add_column :scholarship_applications, :parent_plus_loan, :decimal
    add_column :scholarship_applications, :government_aid, :decimal
    add_column :scholarship_applications, :veterans_assistance, :decimal
    add_column :scholarship_applications, :other_resources_1, :decimal
    add_column :scholarship_applications, :other_resources_2, :decimal
    add_column :scholarship_applications, :books_supplies, :decimal
    add_column :scholarship_applications, :local_transportation, :decimal
    add_column :scholarship_applications, :other_expenses_1, :decimal
    add_column :scholarship_applications, :other_expenses_2, :decimal
    add_column :scholarship_applications, :total_resources, :decimal
    add_column :scholarship_applications, :total_expenses, :decimal
    add_column :scholarship_applications, :remaining_unmet_need, :decimal
  end
end
