import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalResources", "totalExpenses", "remainingUnmetNeed"]

  connect() {
    console.log("Stimulus BudgetForecast controller loaded.");
    this.updateTotals();
  }

  updateTotals() {
    const resourceFields = [
      'student_contribution', 'parent_contribution', 'spouse_contribution',
      'native_corporation_grant_1', 'native_corporation_grant_2',
      'anb_ans_grant', 'pell_grant', 'tuition_exemption',
      'college_work_study', 'college_scholarship', 'alaska_student_loan',
      'stafford_loan', 'alaska_supplemental_loan',
      'alaska_family_education_loan',
      'supplemental_educational_opportunity_grant', 'parent_plus_loan',
      'government_aid', 'veterans_assistance', 'other_resources_1',
      'other_resources_2'
    ];

    const expenseFields = [
      'tuition', 'fees', 'room_board', 'books_supplies',
      'local_transportation', 'personal_expenses', 'other_expenses_1',
      'other_expenses_2'
    ];

    const sumFields = (fields) => fields.reduce((sum, name) => {
      const field = document.getElementById(`scholarship_application_${name}`);
      return sum + (parseFloat(field?.value) || 0);
    }, 0);

    const totalResources = sumFields(resourceFields);
    const totalExpenses = sumFields(expenseFields);
    const remainingUnmetNeed = totalExpenses - totalResources;

    this.totalResourcesTarget.value = totalResources.toFixed(2);
    this.totalExpensesTarget.value = totalExpenses.toFixed(2);
    this.remainingUnmetNeedTarget.value = remainingUnmetNeed.toFixed(2);
  }
}
