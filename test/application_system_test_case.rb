require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    # Containers like the Dependabot review sandbox can't run Chrome's own
    # sandbox and have a small /dev/shm.
    if ENV['CHROME_NO_SANDBOX']
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
    end
  end
end
