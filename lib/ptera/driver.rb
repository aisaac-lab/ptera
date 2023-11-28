require 'capybara'
require 'selenium-webdriver'
require 'colorize'
require_relative "methods"

module Ptera
  class Driver
    include Ptera::Methods
    attr_reader :session

    def initialize(sleep_type: :long, error_handler: ->(ex){ raise ex }, &block)
      key = SecureRandom.base64.delete('=+')
      Capybara.register_driver(key, &block)
      @session = Capybara::Session.new(key)
      @sleep_type    = sleep_type
      @error_handler = error_handler
    end
  
    def execute
      yield(self)
    rescue => ex
      @error_handler.call(ex)
    end

    def take_screenshot(folder_path)
      FileUtils.mkdir_p(folder_path)
      "#{folder_path}/#{SecureRandom.uuid}.png".tap do |file_path|
        @session.driver.save_screenshot(file_path)
      end
    end

    def execute_sleep
      case @sleep_type
      when :long
        sleep(8 + (0...4).to_a.sample)
      when :short
        sleep(3 + (0...4).to_a.sample)
      else
        raise "sleep_type is invalid"
      end
    end

    def logger(label, *bodies)
      object_id_colored = "[#{object_id}]".colorize(:green)
      label_colored = "[#{label}]".colorize(:light_red)

      puts "#{object_id_colored}#{label_colored} #{bodies.join(', ')} #{Time.now.strftime('%m/%d %H:%M:%S')}"
    end
  end
end