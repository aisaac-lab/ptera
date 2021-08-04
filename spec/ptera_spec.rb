require 'spec_helper'

RSpec.describe Ptera do
  it "has a version number" do
    expect(Ptera::VERSION).not_to be nil
  end

  example do
    driver = Ptera::Driver.init(sleep_type: :short, &Ptera::Driver::FIREFOX_NORMAL)

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
    driver = Ptera::Driver.init(
      sleep_type: :short,
      error_handler: ->(ex) { expect(ex).to be_a(Net::ReadTimeout) },
      &Ptera::Driver::FIREFOX_HEADLESS
    )

    driver.execute do
      raise Net::ReadTimeout
    end
  end
end