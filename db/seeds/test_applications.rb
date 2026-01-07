# db/seeds/test_applications.rb
# Create 5 test applications with varied data

puts "Creating test applications..."

test_data = [
  {
    tribal_id: 'TEST-001',
    first_name: 'Sarah',
    middle_initial: 'M',
    last_name: 'Johnson',
    email_address: 'sarah.johnson@test.edu',
    status: 'submitted',
    college_name: 'University of Alaska Fairbanks',
    field_of_study: 'Environmental Science',
    class_standing: 'Junior',
    gpa: 3.75,
    amount_requested: 5000.00,
    current_degree_program: 'Bachelor of Science'
  },
  {
    tribal_id: 'TEST-002',
    first_name: 'Michael',
    middle_initial: 'R',
    last_name: 'Williams',
    email_address: 'michael.williams@test.edu',
    status: 'under_review',
    college_name: 'University of Washington',
    field_of_study: 'Business Administration',
    class_standing: 'Senior',
    gpa: 3.45,
    amount_requested: 7500.00,
    current_degree_program: 'Bachelor of Business'
  },
  {
    tribal_id: 'TEST-003',
    first_name: 'Emily',
    middle_initial: 'K',
    last_name: 'Thompson',
    email_address: 'emily.thompson@test.edu',
    status: 'approved',
    college_name: 'Portland State University',
    field_of_study: 'Social Work',
    class_standing: 'Graduate',
    gpa: 3.90,
    amount_requested: 10000.00,
    amount_awarded: 8000.00,
    current_degree_program: 'Master of Social Work'
  },
  {
    tribal_id: 'TEST-004',
    first_name: 'David',
    middle_initial: 'J',
    last_name: 'Brown',
    email_address: 'david.brown@test.edu',
    status: 'more_info_needed',
    college_name: 'Oregon State University',
    field_of_study: 'Marine Biology',
    class_standing: 'Sophomore',
    gpa: 3.20,
    amount_requested: 4500.00,
    current_degree_program: 'Bachelor of Science'
  },
  {
    tribal_id: 'TEST-005',
    first_name: 'Jessica',
    middle_initial: 'L',
    last_name: 'Martinez',
    email_address: 'jessica.martinez@test.edu',
    status: 'rejected',
    college_name: 'University of Alaska Anchorage',
    field_of_study: 'Nursing',
    class_standing: 'Junior',
    gpa: 2.85,
    amount_requested: 6000.00,
    current_degree_program: 'Bachelor of Science in Nursing'
  }
]

test_data.each do |data|
  # Create student first
  student = Student.find_or_create_by(tribal_id: data[:tribal_id]) do |s|
    s.first_name = data[:first_name]
    s.last_name = data[:last_name]
    s.email_address = data[:email_address]
  end
  puts "Created/found student: #{student.tribal_id}"

  # Check if application already exists for this student this year
  existing = Application.find_by(tribal_id: data[:tribal_id], application_year: Date.current.year)
  if existing
    puts "Skipping - application already exists: #{existing.application_key} for #{existing.full_name}"
    next
  end

  # Create application
  app = Application.new(data)
  app.save!
  puts "Created application: #{app.application_key} for #{app.full_name}"
end

puts "\nDone! Created 5 test applications."
