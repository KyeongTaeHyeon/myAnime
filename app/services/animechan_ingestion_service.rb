require 'net/http'
require 'uri'
require 'json'
require 'cgi'

class AnimechanIngestionService
  PROVIDER = 'animechan'.freeze

  class << self
    def ingest_quotes(anime_name:)
      return 0 unless RateLimitService.can_run?(PROVIDER)

      endpoint = ENV.fetch('QUOTE_API_ENDPOINT', 'https://api.animechan.io/v1')
      endpoint = "https://#{endpoint}" unless endpoint.start_with?('http://', 'https://')
      url = "#{endpoint}/quotes?anime=#{CGI.escape(anime_name.to_s)}"
      uri = URI.parse(url)
      res = Net::HTTP.get_response(uri)

      if res.code.to_i == 429
        RateLimitService.record_rate_limited(PROVIDER, 3600)
        return 0
      end
      raise StandardError, "AnimeChan request failed: #{res.code}" unless res.code.to_i.between?(200, 299)

      parsed = JSON.parse(res.body)
      data = parsed['data']
      records = data.is_a?(Array) ? data : [data].compact

      saved = 0
      Quote.transaction do
        records.each do |item|
          content = item['content']
          character = item.dig('character', 'name')
          anime_title = item.dig('anime', 'name')
          next if content.blank? || character.blank?
          next if Quote.exists?(source: PROVIDER, character_name: character, quote_text: content)

          quote = Quote.new(source: PROVIDER, character_name: character, quote_text: content, raw_json: item.to_json)
          if anime_title.present?
            quote.anime = Anime.where('LOWER(title_romaji) = ? OR LOWER(title_english) = ? OR LOWER(title_native) = ?', anime_title.downcase, anime_title.downcase, anime_title.downcase).first
          end
          quote.save!
          saved += 1
        end
      end

      RateLimitService.record_success(PROVIDER, ENV.fetch('QUOTE_MIN_INTERVAL_MS', '720000').to_i)
      saved
    rescue StandardError => e
      RateLimitService.record_failure(PROVIDER, e.message)
      raise
    end
  end
end
