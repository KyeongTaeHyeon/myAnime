require 'net/http'
require 'uri'
require 'json'

class AnilistIngestionService
  PROVIDER = 'anilist'.freeze

  QUERY = <<~GRAPHQL
    query ($page: Int, $perPage: Int, $season: MediaSeason, $seasonYear: Int) {
      Page(page: $page, perPage: $perPage) {
        media(type: ANIME, season: $season, seasonYear: $seasonYear, sort: POPULARITY_DESC) {
          id
          title { romaji english native }
          status
          season
          seasonYear
          format
          episodes
          duration
          source
          coverImage { large }
          bannerImage
          meanScore
          popularity
        }
      }
    }
  GRAPHQL

  class << self
    def ingest_season(year:, season:, page:, per_page:)
      return 0 unless RateLimitService.can_run?(PROVIDER)

      endpoint = ENV.fetch('ANILIST_ENDPOINT', 'https://graphql.anilist.co')
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req.body = {
        query: QUERY,
        variables: {
          page: page.to_i,
          perPage: per_page.to_i,
          season: season,
          seasonYear: year.to_i
        }
      }.to_json

      res = perform(uri, req)
      handle_limit!(res, default_retry: 60)
      body = JSON.parse(res.body)
      items = body.dig('data', 'Page', 'media') || []

      saved = 0
      Anime.transaction do
        items.each do |media|
          anime = Anime.find_or_initialize_by(anilist_id: media['id'])
          anime.assign_attributes(
            title_romaji: media.dig('title', 'romaji'),
            title_english: media.dig('title', 'english'),
            title_native: media.dig('title', 'native'),
            status: media['status'],
            season: media['season'],
            season_year: media['seasonYear'],
            format: media['format'],
            episodes: media['episodes'],
            duration: media['duration'],
            source: media['source'],
            cover_image_url: media.dig('coverImage', 'large'),
            banner_image_url: media['bannerImage'],
            mean_score: media['meanScore'],
            popularity: media['popularity'],
            raw_json: media.to_json
          )
          anime.save!
          saved += 1
        end
      end

      RateLimitService.record_success(PROVIDER, ENV.fetch('ANILIST_MIN_INTERVAL_MS', '2000').to_i)
      saved
    rescue StandardError => e
      RateLimitService.record_failure(PROVIDER, e.message)
      raise
    end

    private

    def perform(uri, req)
      max_retries = ENV.fetch('HTTP_MAX_RETRIES', '2').to_i
      open_timeout = ENV.fetch('HTTP_OPEN_TIMEOUT_SEC', '5').to_i
      read_timeout = ENV.fetch('HTTP_READ_TIMEOUT_SEC', '15').to_i
      write_timeout = ENV.fetch('HTTP_WRITE_TIMEOUT_SEC', '15').to_i
      attempts = 0

      begin
        attempts += 1
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.open_timeout = open_timeout
          http.read_timeout = read_timeout
          http.write_timeout = write_timeout if http.respond_to?(:write_timeout=)
          http.request(req)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, EOFError => e
        raise if attempts > max_retries

        sleep(0.3 * attempts)
        retry
      end
    end

    def handle_limit!(res, default_retry:)
      if res.code.to_i == 429
        retry_after = res['Retry-After'].to_i
        retry_after = default_retry if retry_after <= 0
        RateLimitService.record_rate_limited(PROVIDER, retry_after)
        raise StandardError, 'rate_limited'
      end

      return if res.code.to_i.between?(200, 299)

      raise StandardError, "AniList request failed: #{res.code}"
    end
  end
end
