require 'net/http'
require 'uri'
require 'json'
require 'time'

class NewsIngestionService
  PROVIDER = 'newsapi'.freeze

  class << self
    def ingest_news(query: nil, language: nil)
      return 0 unless RateLimitService.can_run?(PROVIDER)

      api_key = ENV['NEWS_API_KEY'].to_s
      raise StandardError, 'NEWS_API_KEY is not configured' if api_key.blank?

      endpoint = ENV.fetch('NEWS_API_ENDPOINT', 'https://newsapi.org/v2/everything')
      endpoint = "https://#{endpoint}" unless endpoint.start_with?('http://', 'https://')
      q = query.presence || ENV.fetch('NEWS_API_QUERY', 'anime OR manga')
      lang = language.presence

      uri = URI.parse(endpoint)
      params = { q: q, pageSize: 100 }
      params[:language] = lang if lang.present?
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req['X-Api-Key'] = api_key

      res = perform(uri, req)

      if res.code.to_i == 429
        retry_after = res['Retry-After'].to_i
        retry_after = 900 if retry_after <= 0
        RateLimitService.record_rate_limited(PROVIDER, retry_after)
        return 0
      end
      raise StandardError, "News API request failed: #{res.code}" unless res.code.to_i.between?(200, 299)

      parsed = JSON.parse(res.body)
      articles = parsed['articles'] || []
      saved = 0

      NewsArticle.transaction do
        articles.each do |item|
          url = item['url']
          next if url.blank?
          next if NewsArticle.exists?(provider: PROVIDER, external_id: url)

          NewsArticle.create!(
            provider: PROVIDER,
            external_id: url,
            title: item['title'],
            description: item['description'],
            url: url,
            image_url: item['urlToImage'],
            published_at: parse_time(item['publishedAt']),
            raw_json: item.to_json
          )
          saved += 1
        end
      end

      RateLimitService.record_success(PROVIDER, ENV.fetch('NEWS_MIN_INTERVAL_MS', '900000').to_i)
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
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, EOFError
        raise if attempts > max_retries

        sleep(0.3 * attempts)
        retry
      end
    end

    def parse_time(value)
      return nil if value.blank?

      Time.iso8601(value)
    rescue StandardError
      nil
    end
  end
end
