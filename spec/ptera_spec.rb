require 'spec_helper'

RSpec.describe Ptera do
  it "has a version number" do
    expect(Ptera::VERSION).not_to be nil
  end

  example do
    driver = Ptera::Driver.init(sleep_type: :short, error_handler: ->(ex) { raise ex }) do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['devtools.jsonview.enabled'] = false
      options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
      options.headless!
      profile["general.useragent.override"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
      Capybara::Selenium::Driver.new(app, options: options)
    end

    $mock = nil
    driver.execute do
      Visit 'https://www.facebook.com/'
      Fill '#email', with: 'test@test.com'
      Fill '#pass', with: 'passw0rd'
      $mock = @session.find('#email').value
    end

    expect($mock).to eq('test@test.com')
  end

  example do
    driver = Ptera::Driver.init(sleep_type: :short, error_handler: ->(ex) { expect(ex).to be_a(Net::ReadTimeout) }) do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['devtools.jsonview.enabled'] = false
      options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
      options.headless!
      profile["general.useragent.override"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
      Capybara::Selenium::Driver.new(app, options: options)
    end

    driver.execute do
      raise Net::ReadTimeout
    end
  end
end