require './advocate.rb'

continue = 'y'

def input_options
  puts "  1. Add an advocate \n
  2. Add junior advocates \n
  3. Add states for advocate \n
  4. Add cases for advocate \n
  5. Reject a case. \n
  6. Display all advocates \n
  7. Display all cases under a state"
end

def add_an_advocate(params={})
  puts 'Add an advocate:'
  params['code'] = gets.chomp 
  Advocate.new(params)
  if $errors.size > 0
    puts $errors[0]
  else
    puts 'Output'
    puts "Advocate added #{params['code']}"

    puts "Display: \n Advocate added #{params['code']}"
  end
end

def add_advocate_with_senior(params={})
  puts 'Senior Advocate ID::'
  params['senior_code'] = gets.chomp
  puts 'Junior ID:'
  params['code'] = gets.chomp
  Advocate.new(params)
  puts "Output​ : \nAdvocate added #{params['code']} under #{params['senior_code']}"
  Advocate.get_detailed_view(params['code'])
end

def add_practicing_states(params={})
  puts 'Advocate ID:'
  code = gets.chomp
  puts 'Practicing State:'
  params['states'] = gets.chomp
  get_and_update_advocate(params, code)
end

def get_and_update_advocate(params, code)
  advocate = Advocate.find_by_code(code)
  if advocate
    advocate.update(params)
  else
    puts ('Advocate not found')
  end
end

def generate_case_insertion_success(to_block, params, code)
  if to_block
    puts "Case #{params['cases']} is added in Block list for #{code}."
  else
    puts "Case #{params['cases']} added for #{code}."
  end
end

def generate_case_insertion_failure(to_block, params, code)
  puts $errors
end

def add_cases(to_block=false, params={})
  puts 'Advocate ID:'
  code = gets.chomp
  puts 'Case ID'
  params['cases'] = gets.chomp
  puts 'Practicing State:'
  params['case_state'] = gets.chomp.upcase
  get_and_update_advocate(params, code)
  if $errors.size > 0
    generate_case_insertion_failure(to_block, params, code)
  else
    generate_case_insertion_success(to_block, params, code)
  end
end

def get_advocate_by_state_id
  puts 'State Id:'
  state_code = gets.chomp.upcase
  Advocate.list_by_state(state_code)
end

def manage_user_response(option)
  case option
  when '1'
    add_an_advocate
  when '2'
    add_advocate_with_senior
  when '3'
    add_practicing_states
  when '4'
    add_cases(false)
  when '5'
    params = {}
    params['case_status'] = 'blocked'
    add_cases(true, params)
  when '6'
    Advocate.list_all()
  when '7'
    get_advocate_by_state_id
  else
    puts 'Unknow opertion :)'
  end
end


while (continue.downcase == 'y')
  $errors = []
  puts 'SELECT AN OPTION'
  puts "#{input_options}"
  option = gets.chomp
  errors, result = manage_user_response(option)
  puts "\n \ncontinue? y : any other key"
  continue = gets.chomp
end
