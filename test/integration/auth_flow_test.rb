require 'test_helper'

class AuthFlowTest < ActionDispatch::IntegrationTest
  test 'register and login returns token' do
    email = "user#{Time.now.to_i}@example.com"
    password = 'password123!'

    post '/api/auth/register', params: { email: email, password: password, displayName: 'tester' }
    assert_response :success
    body = JSON.parse(response.body)
    assert body['accessToken'].present?

    post '/api/auth/login', params: { email: email, password: password }
    assert_response :success
    login = JSON.parse(response.body)
    assert login['accessToken'].present?
  end
end
