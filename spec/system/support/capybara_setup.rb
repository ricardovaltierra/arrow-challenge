# frozen_string_literal: true

# See https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing

# There's no need for increasing the "max wait time" with Cuprite, like
# developers often do:
Capybara.default_max_wait_time = 2

# Configure the server to listen to all hosts:
Capybara.server_host = '0.0.0.0'

# Use a hostname that could be resolved in the internal Docker network
Capybara.app_host = "http://#{`hostname`.strip&.downcase || '0.0.0.0'}"

# Which domain to use when setting cookies directly in tests.
CAPYBARA_COOKIE_DOMAIN = URI.parse(Capybara.app_host).host.then do |host|
  # If host is a top-level domain
  next host unless host.include?('.')

  ".#{host}"
end

# Normalize whitespaces when using `has_text?` and similar matchers,
# i.e., ignore newlines, trailing spaces, etc.
# That makes tests less dependent on slightly UI changes.
Capybara.default_normalize_ws = true

# Where to store system tests artifacts (e.g. screenshots, downloaded files, etc.).
# It could be useful to be able to configure this path from the outside (e.g., on CI).
Capybara.save_path = ENV.fetch('CAPYBARA_ARTIFACTS', './tmp/capybara')

Capybara.singleton_class.prepend(Module.new do
  attr_accessor :last_used_session

  # Manipulates a different browser session, allowing multiple independent
  # sessions within a single test scenario.
  # Specially useful for testing real-time features.
  def using_session(name, &block)
    self.last_used_session = name
    super
  ensure
    self.last_used_session = nil
  end
end)
