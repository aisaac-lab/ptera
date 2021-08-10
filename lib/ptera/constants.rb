module Ptera
  FIREFOX_HEADLESS = proc { |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['devtools.jsonview.enabled'] = false
    options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
    options.headless!
    # profile["general.useragent.override"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
    Capybara::Selenium::Driver.new(app, options: options)
  }

  FIREFOX_NORMAL = proc { |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['devtools.jsonview.enabled'] = false
    options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
    # options.headless!
    # profile["general.useragent.override"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
    Capybara::Selenium::Driver.new(app, options: options)
  }

  FIREFOX_WITH_PROXY = proc { |proxy_host|
    proc { |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['devtools.jsonview.enabled'] = false
      profile.proxy = Selenium::WebDriver::Proxy.new(http: proxy_host, ssl: proxy_host)
      options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
      Capybara::Selenium::Driver.new(app, options: options)
    }
  }

  FIREFOX_WITH_DOWNLOAD = proc { |download_dir|
    proc { |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['devtools.jsonview.enabled'] = false

      FileUtils.mkdir_p(download_dir)
      profile['browser.download.dir'] = download_dir.to_s
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.download.manager.showWhenStarting'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv"

      options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
      # options.headless!

      Capybara::Selenium::Driver.new(app, options: options)
    }
  }
end
