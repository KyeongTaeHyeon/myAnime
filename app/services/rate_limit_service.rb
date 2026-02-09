class RateLimitService
  class << self
    def can_run?(provider)
      state = IngestionState.find_or_create_by!(provider: provider)
      state.next_allowed_at.blank? || Time.current >= state.next_allowed_at
    end

    def record_success(provider, min_interval_ms)
      state = IngestionState.find_or_create_by!(provider: provider)
      state.update!(next_allowed_at: Time.current + (min_interval_ms.to_i / 1000.0), last_error: nil)
    end

    def record_failure(provider, error)
      state = IngestionState.find_or_create_by!(provider: provider)
      state.update!(last_error: error.to_s)
    end

    def record_rate_limited(provider, retry_after_seconds)
      state = IngestionState.find_or_create_by!(provider: provider)
      state.update!(next_allowed_at: Time.current + retry_after_seconds.to_i.seconds, last_error: 'rate_limited')
    end
  end
end
