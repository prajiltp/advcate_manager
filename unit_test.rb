gem 'test-unit'
require './advocate.rb'
require 'test/unit'
require 'pry'
class TestAdvcate < Test::Unit::TestCase
  def test_initializer
    params = {}
    params['code'] = '100'
    assert_equal(Advocate.new(params).class,Advocate)
  end

  def test_update
    params = {}
    code = '100'
    params['tates'] ='TN'
    advocate = Advocate.find_by_code(code)
    assert_equal(advocate.update(params), [])
  end
end
