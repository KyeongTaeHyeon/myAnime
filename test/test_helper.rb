ENV['RAILS_ENV'] ||= 'test'
ENV['JWT_SECRET'] ||= 'test_secret_test_secret_test_secret'

require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  parallelize(workers: 1)
end
