
class Advocate
  attr_accessor :id, :code, :states, :cases, :senior

  @@list = {}

  def initialize(params)
    advocate = Advocate.find_by_code(params['code']) if params['code']
    if advocate
      $errors << 'The advocate with name already exists'
    else
      @code = self.class.case_insentive(params["code"])
      @states = assign_states(params["states"])
      @cases = assign_cases(params["cases"], params['case_state'], params['case_status'])
      @senior = assign_senior(params["senior_code"])
      add_to_list
    end
  end

  class << self
    def find_by_code(code)
      @@list[code]
    end

    def case_insentive(value)
      return "" if value.nil?
      value.downcase.strip
    end

    def get_detailed_view(code)
      advocate = self.find_by_code(code)
      if advocate
        advocate.senior.nil? ? advocate.show_details_of() : get_detailed_view(advocate.senior.code)
      else
        $errors << 'Invalid advocate'
      end
    end

    def list_all()
      @@list.each do |key, value|
        unless value.senior
          value.show_details_of()
        end
      end
    end

    def list_by_state(state_code)
      puts "#{state_code}:"
      @@list.each do |key, value|
        if value.states.include? state_code
          approved_list, rejected_list = value.get_case_details(state_code)
          puts "#{value.code}: #{approved_list}"
        end
      end
    end
  end

  def update(params)
    @states = self.states.push(assign_states(params["states"]).last).uniq.compact
    @cases = self.cases.push(assign_cases(params["cases"], params['case_state'], params['case_status']).last).uniq.compact
  end

  def show_details_of
    puts "Advocate Name: #{self.code}"
    puts "Practicing states: #{self.get_states}"
    case_details
    juniors_list = @@list.collect{|key, hash|  hash if (hash.senior && hash.senior == self)}.compact
    juniors_list.each do |junior|
      puts "-Advocate Name: #{junior.code}"
      puts "-Practicing states: #{junior.get_states}"
      junior.case_details('-')
    end
  end

  def invalid_state(state_code, com)
    state_code != com[:state]
  end

  def get_case_details(state_code=nil)
    approved_list =[]
    rejected_list = []
    self.cases.each do |com|
      next  if (state_code && invalid_state(state_code, com))
      if com[:status] == "approved"
        approved_list.push("#{com[:code]}-#{com[:state]}")
      else
        rejected_list.push("#{com[:code]}-#{com[:state]}")
      end
    end
    [approved_list.uniq.compact.join(','), rejected_list.uniq.compact.join(',')]
  end

  def case_details(sp_char=nil)
    approved_list, rejected_list = get_case_details
    puts "#{sp_char}Practicing Cases: #{approved_list}"
    puts "#{sp_char}BlockList Cases: #{rejected_list}"
  end

  def get_states
    states.join(',')
  end

  def assign_senior(advocate_code)
    return nil unless advocate_code
    advocate = Advocate.find_by_code(advocate_code.downcase)
    $errors << 'Senior not found' unless advocate
    advocate
  end

  def assign_states(states)
    return [] if (states.nil? || states.empty?)
    state_list = states.split(",").map(&:upcase).compact
    unless self.senior
      puts "State Added #{state_list.join(',')} for #{code}."
      return state_list
    end
    state_list
    state_list.each do |item|
      if self.senior.get_states.include? item
        puts "State Added #{item} for #{code}."
      else
        state_list.delete(item)
        puts "Cannot add #{item} for #{code}."
      end
    end
    state_list
  end

  def assign_cases(cases, case_state, status)
    return [] if (cases.nil? || cases.empty?)
    cases_list = cases.split(",")
    @error = validate_not_rejected(cases, case_state) if self.senior
    unless @error
      cases_list.collect{ |item| parse_case(item, case_state.upcase, status) }
    else
      []
    end
  end

  def parse_case(cases, case_state, status)
    { 
      state: case_state, code: self.class.case_insentive(cases), status: (status || 'approved')
    }
  end

  def validate_not_rejected(cases, case_state)
    if senior.cases.select {|com| com[:code] == cases && com[:status]=='blocked' && com[:state]==case_state}.size > 0
      $errors << "Cannot add #{cases} case under #{code}."
      true
    else
      false
    end
  end

  def add_to_list
    @@list[self.code] = self
  end
end