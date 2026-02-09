require 'test_helper'
require 'jwt'

class AnimeLikesAndPaginationTest < ActionDispatch::IntegrationTest
  setup do
    @anime = Anime.create!(anilist_id: 10_001, title_romaji: 'Naruto', season: 'WINTER', season_year: 2025)
    @user = User.create!(
      email: "likes#{Time.now.to_i}@example.com",
      display_name: 'likes',
      role: 'USER',
      password: 'password123!',
      password_confirmation: 'password123!'
    )
  end

  test 'like create and destroy requires auth and works with token' do
    post "/api/anime/#{@anime.id}/like"
    assert_response :unauthorized

    post "/api/anime/#{@anime.id}/like", headers: { 'Authorization' => "Bearer #{token_for(@user)}" }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body['liked']
    assert_equal 1, body['count']

    delete "/api/anime/#{@anime.id}/like", headers: { 'Authorization' => "Bearer #{token_for(@user)}" }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal false, body['liked']
    assert_equal 0, body['count']
  end

  test 'anime index caps size to 100' do
    120.times do |i|
      Anime.create!(anilist_id: 20_000 + i, title_romaji: "Title #{i}", season: 'WINTER', season_year: 2025)
    end

    get '/api/anime', params: { page: 0, size: 500 }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 100, body['size']
    assert_equal 100, body['numberOfElements']
  end

  private

  def token_for(user)
    now = Time.now.to_i
    JWT.encode({ sub: user.email, role: user.role, iat: now, exp: now + 3600 }, ENV.fetch('JWT_SECRET'), 'HS256')
  end
end
