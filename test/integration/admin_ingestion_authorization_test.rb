require 'test_helper'
require 'jwt'

class AdminIngestionAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "user#{Time.now.to_i}@example.com",
      display_name: 'user',
      role: 'USER',
      password: 'password123!',
      password_confirmation: 'password123!'
    )
    @admin = User.create!(
      email: "admin#{Time.now.to_i}@example.com",
      display_name: 'admin',
      role: 'ADMIN',
      password: 'password123!',
      password_confirmation: 'password123!'
    )
  end

  test 'non-admin cannot access admin ingestion endpoints' do
    post '/api/admin/ingest/status', headers: { 'Authorization' => "Bearer #{token_for(@user)}" }
    assert_response :forbidden
  end

  test 'admin can access admin ingestion endpoints' do
    post '/api/admin/ingest/status', headers: { 'Authorization' => "Bearer #{token_for(@admin)}" }
    assert_response :success
  end

  private

  def token_for(user)
    now = Time.now.to_i
    JWT.encode({ sub: user.email, role: user.role, iat: now, exp: now + 3600 }, ENV.fetch('JWT_SECRET'), 'HS256')
  end
end
