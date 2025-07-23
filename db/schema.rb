# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_19_000000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "scholarship_applications", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "middle_initial"
    t.string "previous_maiden_name"
    t.string "student_id"
    t.date "date_of_birth"
    t.string "place_of_birth"
    t.string "marital_status"
    t.integer "number_of_dependents"
    t.string "tribe_enrolled"
    t.string "previous_scholarship"
    t.string "previous_scholarship_year"
    t.string "preferred_contact"
    t.string "email_address"
    t.string "mailing_address_permanent"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "mailing_address_school"
    t.string "city_school"
    t.string "state_school"
    t.string "zip_code_school"
    t.string "permanent_phone"
    t.string "school_phone"
    t.string "education_earned"
    t.string "school_name"
    t.string "school_city"
    t.string "school_earned_in"
    t.string "college_name"
    t.string "college_financial_aid_office"
    t.string "college_phone"
    t.string "college_fax"
    t.string "college_financial_aid_mailing_address"
    t.string "college_city"
    t.string "college_state"
    t.string "college_zip_code"
    t.string "college_term_type"
    t.string "deadline_fee_payments"
    t.string "credits_taking"
    t.string "current_degree_program"
    t.date "expected_graduation_date"
    t.string "class_standing"
    t.string "field_of_study"
    t.string "minor"
    t.text "educational_goals"
    t.boolean "certify_information"
    t.string "signature"
    t.date "date"
    t.boolean "certify_not_defaulting"
    t.decimal "tuition", precision: 10, scale: 2
    t.decimal "fees", precision: 10, scale: 2
    t.decimal "room_board", precision: 10, scale: 2
    t.decimal "books", precision: 10, scale: 2
    t.decimal "transportation", precision: 10, scale: 2
    t.decimal "personal_expenses", precision: 10, scale: 2
    t.string "other_expenses"
    t.text "resources_college_expenses"
    t.decimal "amount_requested", precision: 10, scale: 2
    t.string "status"
    t.string "reference_number"
    t.string "release_signature"
    t.date "release_date"
    t.string "enrollment_last_name"
    t.string "enrollment_first_name"
    t.string "enrollment_middle_name"
    t.date "enrollment_date_of_birth"
    t.string "enrollment_sex"
    t.string "enrollment_phone"
    t.string "enrollment_place_of_birth"
    t.string "enrollment_mailing_city"
    t.string "enrollment_mailing_state"
    t.string "enrollment_mailing_zip"
    t.string "financial_student_name"
    t.string "financial_student_id"
    t.string "financial_aid_status"
    t.string "budget_period"
    t.text "student_resources"
    t.string "photo_release_signature"
    t.date "photo_release_date"
    t.string "parental_release_signature"
    t.date "parental_release_date"
    t.string "arpa_student_name"
    t.boolean "arpa_authorization"
    t.string "arpa_signature"
    t.date "arpa_date"
    t.decimal "student_contribution", precision: 10, scale: 2
    t.decimal "parent_contribution", precision: 10, scale: 2
    t.decimal "spouse_contribution", precision: 10, scale: 2
    t.string "native_corp_grant1_name"
    t.decimal "native_corp_grant1_amount", precision: 10, scale: 2
    t.string "native_corp_grant2_name"
    t.decimal "native_corp_grant2_amount", precision: 10, scale: 2
    t.decimal "anb_ans_grant", precision: 10, scale: 2
    t.decimal "pell_grant", precision: 10, scale: 2
    t.decimal "tuition_exemption", precision: 10, scale: 2
    t.decimal "college_work_study", precision: 10, scale: 2
    t.string "college_scholarship_name"
    t.decimal "college_scholarship_amount", precision: 10, scale: 2
    t.decimal "alaska_student_loan", precision: 10, scale: 2
    t.decimal "stafford_loan", precision: 10, scale: 2
    t.decimal "alaska_supplemental_loan", precision: 10, scale: 2
    t.decimal "alaska_family_education_loan", precision: 10, scale: 2
    t.decimal "seog_grant", precision: 10, scale: 2
    t.decimal "parent_plus_loan", precision: 10, scale: 2
    t.decimal "government_assistance", precision: 10, scale: 2
    t.decimal "veterans_assistance", precision: 10, scale: 2
    t.string "other_resource1_name"
    t.decimal "other_resource1_amount", precision: 10, scale: 2
    t.string "other_resource2_name"
    t.decimal "other_resource2_amount", precision: 10, scale: 2
    t.string "other_expense1_name"
    t.decimal "other_expense1_amount", precision: 10, scale: 2
    t.string "other_expense2_name"
    t.decimal "other_expense2_amount", precision: 10, scale: 2
    t.decimal "total_resources", precision: 10, scale: 2
    t.decimal "total_expenses", precision: 10, scale: 2
    t.decimal "total_expenses_calc", precision: 10, scale: 2
    t.decimal "minus_total_resources", precision: 10, scale: 2
    t.decimal "unmet_need", precision: 10, scale: 2
    t.text "cover_remaining_need"
    t.string "financial_college_name"
    t.string "financial_student_signature"
    t.date "financial_student_date"
    t.string "financial_aid_status_other_text"
    t.date "budget_period_from"
    t.date "budget_period_to"
    t.string "budget_period_type"
    t.decimal "fna_family_fall", precision: 10, scale: 2
    t.decimal "fna_family_winter", precision: 10, scale: 2
    t.decimal "fna_family_spring", precision: 10, scale: 2
    t.decimal "fna_family_summer", precision: 10, scale: 2
    t.decimal "fna_family_total", precision: 10, scale: 2
    t.decimal "fna_savings_fall", precision: 10, scale: 2
    t.decimal "fna_savings_winter", precision: 10, scale: 2
    t.decimal "fna_savings_spring", precision: 10, scale: 2
    t.decimal "fna_savings_summer", precision: 10, scale: 2
    t.decimal "fna_savings_total", precision: 10, scale: 2
    t.decimal "fna_scholarships_fall", precision: 10, scale: 2
    t.decimal "fna_scholarships_winter", precision: 10, scale: 2
    t.decimal "fna_scholarships_spring", precision: 10, scale: 2
    t.decimal "fna_scholarships_summer", precision: 10, scale: 2
    t.decimal "fna_scholarships_total", precision: 10, scale: 2
    t.decimal "fna_asl_fall", precision: 10, scale: 2
    t.decimal "fna_asl_winter", precision: 10, scale: 2
    t.decimal "fna_asl_spring", precision: 10, scale: 2
    t.decimal "fna_asl_summer", precision: 10, scale: 2
    t.decimal "fna_asl_total", precision: 10, scale: 2
    t.decimal "fna_school_schol_fall", precision: 10, scale: 2
    t.decimal "fna_school_schol_winter", precision: 10, scale: 2
    t.decimal "fna_school_schol_spring", precision: 10, scale: 2
    t.decimal "fna_school_schol_summer", precision: 10, scale: 2
    t.decimal "fna_school_schol_total", precision: 10, scale: 2
    t.decimal "fna_work_study_fall", precision: 10, scale: 2
    t.decimal "fna_work_study_winter", precision: 10, scale: 2
    t.decimal "fna_work_study_spring", precision: 10, scale: 2
    t.decimal "fna_work_study_summer", precision: 10, scale: 2
    t.decimal "fna_work_study_total", precision: 10, scale: 2
    t.decimal "fna_pell_fall", precision: 10, scale: 2
    t.decimal "fna_pell_winter", precision: 10, scale: 2
    t.decimal "fna_pell_spring", precision: 10, scale: 2
    t.decimal "fna_pell_summer", precision: 10, scale: 2
    t.decimal "fna_pell_total", precision: 10, scale: 2
    t.decimal "fna_seog_fall", precision: 10, scale: 2
    t.decimal "fna_seog_winter", precision: 10, scale: 2
    t.decimal "fna_seog_spring", precision: 10, scale: 2
    t.decimal "fna_seog_summer", precision: 10, scale: 2
    t.decimal "fna_seog_total", precision: 10, scale: 2
    t.decimal "fna_stafford_fall", precision: 10, scale: 2
    t.decimal "fna_stafford_winter", precision: 10, scale: 2
    t.decimal "fna_stafford_spring", precision: 10, scale: 2
    t.decimal "fna_stafford_summer", precision: 10, scale: 2
    t.decimal "fna_stafford_total", precision: 10, scale: 2
    t.decimal "fna_veteran_fall", precision: 10, scale: 2
    t.decimal "fna_veteran_winter", precision: 10, scale: 2
    t.decimal "fna_veteran_spring", precision: 10, scale: 2
    t.decimal "fna_veteran_summer", precision: 10, scale: 2
    t.decimal "fna_veteran_total", precision: 10, scale: 2
    t.decimal "fna_tuition_waiver_fall", precision: 10, scale: 2
    t.decimal "fna_tuition_waiver_winter", precision: 10, scale: 2
    t.decimal "fna_tuition_waiver_spring", precision: 10, scale: 2
    t.decimal "fna_tuition_waiver_summer", precision: 10, scale: 2
    t.decimal "fna_tuition_waiver_total", precision: 10, scale: 2
    t.decimal "fna_perkins_fall", precision: 10, scale: 2
    t.decimal "fna_perkins_winter", precision: 10, scale: 2
    t.decimal "fna_perkins_spring", precision: 10, scale: 2
    t.decimal "fna_perkins_summer", precision: 10, scale: 2
    t.decimal "fna_perkins_total", precision: 10, scale: 2
    t.string "fna_other1_name"
    t.decimal "fna_other1_fall", precision: 10, scale: 2
    t.decimal "fna_other1_winter", precision: 10, scale: 2
    t.decimal "fna_other1_spring", precision: 10, scale: 2
    t.decimal "fna_other1_summer", precision: 10, scale: 2
    t.decimal "fna_other1_total", precision: 10, scale: 2
    t.string "fna_other2_name"
    t.decimal "fna_other2_fall", precision: 10, scale: 2
    t.decimal "fna_other2_winter", precision: 10, scale: 2
    t.decimal "fna_other2_spring", precision: 10, scale: 2
    t.decimal "fna_other2_summer", precision: 10, scale: 2
    t.decimal "fna_other2_total", precision: 10, scale: 2
    t.decimal "fna_tuition_fees", precision: 10, scale: 2
    t.decimal "fna_room_board", precision: 10, scale: 2
    t.decimal "fna_books", precision: 10, scale: 2
    t.decimal "fna_transportation", precision: 10, scale: 2
    t.decimal "fna_personal", precision: 10, scale: 2
    t.string "fna_other_expense1_name"
    t.decimal "fna_other_expense1", precision: 10, scale: 2
    t.string "fna_other_expense2_name"
    t.decimal "fna_other_expense2", precision: 10, scale: 2
    t.string "financial_aid_officer_signature"
    t.date "financial_aid_officer_date"
    t.string "fao_address"
    t.string "fao_telephone"
    t.string "fao_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "school_city_state"
    t.string "previous_college1_name"
    t.string "previous_college1_dates"
    t.integer "previous_college1_credits"
    t.string "previous_college1_degree"
    t.string "previous_college2_name"
    t.string "previous_college2_dates"
    t.integer "previous_college2_credits"
    t.string "previous_college2_degree"
    t.string "previous_college3_name"
    t.string "previous_college3_dates"
    t.integer "previous_college3_credits"
    t.string "previous_college3_degree"
    t.decimal "fna_total_cost"
    t.decimal "fna_total_resources"
    t.decimal "fna_unmet_need"
    t.string "finance_grant_number"
    t.string "board_status"
    t.json "custom_fields", default: {}
    t.text "internal_notes"
    t.decimal "gpa", precision: 4, scale: 2
    t.boolean "sta_enroll", default: false
    t.boolean "transcript_overall", default: false
    t.boolean "acceptance_letter", default: false
    t.boolean "fafsa", default: false
    t.string "vendor_id"
    t.string "committee_action"
    t.decimal "amount_awarded", precision: 10, scale: 2
    t.string "term"
    t.string "arpa_application_page"
    t.decimal "arpa_amount_awarded", precision: 10, scale: 2
    t.decimal "distribution_he_fall_2023", precision: 10, scale: 2
    t.decimal "distribution_he_spring_2022_2023", precision: 10, scale: 2
    t.decimal "distribution_he_summer_2024", precision: 10, scale: 2
    t.decimal "distribution_he_summer_2023", precision: 10, scale: 2
    t.decimal "distribution_arpa_fall_2022", precision: 10, scale: 2
    t.decimal "distribution_arpa_spring_2022_2023", precision: 10, scale: 2
    t.decimal "distribution_arpa_spring_2023", precision: 10, scale: 2
    t.decimal "distribution_arpa_summer_2023", precision: 10, scale: 2
    t.decimal "ties_out_year_payments", precision: 10, scale: 2
    t.boolean "transcript_fall_term", default: false
    t.boolean "transcript_winter_term", default: false
    t.boolean "transcript_spring_term", default: false
    t.boolean "transcript_summer_term", default: false
    t.date "school_month_year_earned"
    t.date "previous_college1_start_date"
    t.date "previous_college1_end_date"
    t.date "previous_college2_start_date"
    t.date "previous_college2_end_date"
    t.date "previous_college3_start_date"
    t.date "previous_college3_end_date"
    t.date "deadline_fee_payments_fall"
    t.date "deadline_fee_payments_winter"
    t.date "deadline_fee_payments_spring"
    t.date "deadline_fee_payments_summer"
    t.integer "credits_taking_fall"
    t.integer "credits_taking_winter"
    t.integer "credits_taking_spring"
    t.integer "credits_taking_summer"
    t.index ["board_status"], name: "index_scholarship_applications_on_board_status"
    t.index ["finance_grant_number"], name: "index_scholarship_applications_on_finance_grant_number"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
