VCR.configure do |c|
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
      allow_playback_repeats: true,
      match_requests_on: [:method, :uri]
  }
end