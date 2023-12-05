require 'spec_helper'

RSpec.describe Ptera do
  it "has a version number" do
    expect(Ptera::VERSION).not_to be nil
  end

  example "1" do
    driver = Ptera::Driver.new(sleep_type: :short, &Ptera::FIREFOX_NORMAL)

    var1 = 1
    element = nil

    driver.execute do |d|
      expect(var1).to eq(1)

      d.visit 'https://www.facebook.com/'
      d.fill '#email', with: 'test@test.com'
      d.fill '#pass', with: 'passw0rd'

      element = d.find('#email').value

      d.click("button[name=login]")
    end

    expect(element).to eq('test@test.com')
  end

  example "2" do
    driver = Ptera::Driver.new(sleep_type: :short, &Ptera::FIREFOX_NORMAL)

    driver.execute do |d|
      d.visit 'https://twitter.com/hiratahirata14/status/1714562795264725099', ensure_has: 'a[href="https://t.co/jyEgbwIMNK"]:first-child'

      new_window = d.session.window_opened_by { d.click('a[href="https://t.co/jyEgbwIMNK"]:first-child') }
      d.session.within_window new_window do
        expect(d.session.current_url).to eq('https://prtimes.jp/main/html/rd/p/000001694.000002734.html')
      end
    end
  end

  example "3" do
    driver = Ptera::Driver.new(sleep_type: :short, &Ptera::FIREFOX_NORMAL)

    driver.execute do |d|
      d.visit 'https://www.google.com/'
    end
  end

  example "4" do
    driver = Ptera::Driver.new(sleep_type: :short, &Ptera::FIREFOX_NORMAL)
    driver.visit 'https://www.google.com/'
    path = driver.take_screenshot
    expect(1000 < File.read(path).length).to eq(true)
  end
end