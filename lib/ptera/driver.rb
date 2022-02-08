require 'capybara'
require 'selenium-webdriver'
require 'colorize'

module Ptera
  class Driver
    attr_reader :session

    def initialize(session:, sleep_type: :long, error_handler: ->(ex){ raise ex })
      @session       = session
      @sleep_type    = sleep_type
      @error_handler = error_handler
    end

    def self.init(sleep_type: :long, error_handler: ->(ex){ raise ex }, &block)
      key = SecureRandom.base64.delete('=+')
      Capybara.register_driver key, &block
      session = Capybara::Session.new(key)
      self.new(session: session, sleep_type: sleep_type, error_handler: error_handler)
    end

    def execute(&block)
      instance_eval(&block)
    rescue Net::ReadTimeout => ex
      puts "Retry!"
      sleep 10
      begin
        instance_eval(&block)
      rescue => ex
        @error_handler.call(ex)
      end
    rescue => ex
      @error_handler.call(ex)
    end

    def Visit(url, ensure_has: nil, max_retry_count: 3)
      encoded_url = Addressable::URI.encode(url)

      @session.visit encoded_url

      unless ensure_has.nil?
        try = 0
        until Has? ensure_has
          @session.visit encoded_url
          try += 1
          raise "error url: #{url}, ensure_has: #{ensure_has}" if max_retry_count < try
        end
      end

      logger __method__, url
      execute_sleep
    end

    def Find(*args, **options)
      retry_count = options.delete(:retry_count) || 0
      maybe = options.delete(:maybe) || false
      current_try = 0
      element = nil

      begin
        current_try += 1
        element = @session.find(*args, **options)
        logger __method__, args.first
      rescue Capybara::ElementNotFound => ex
        unless maybe
          if current_try <= retry_count
            logger "RETRY(#{current_try}) #{__method__}", args.first
            @session.refresh
            sleep (7...18).to_a.sample
            retry
          end
          raise ex
        end
      end

      element
    end

    def Has?(*args, **option)
      !!Find(*args, maybe: true, **option)
    end

    def Click(*args, **options)
      Find(*args, **options).click

      # begin
      #   element.click
      # rescue Selenium::WebDriver::Error::ElementNotInteractableError
      #   element.evaluate_script('this.click()')
      # end

      logger __method__, args.first
      execute_sleep
    end

    def ClickMaybe(*args, **options)
      if @session.find_all(*args, **options).count == 1
        Click(*args, **options)
      else
        logger __method__, "#{args.first} is not found"
      end
    end

    def ScrollTo(kind)
      case kind
      when :top
        @session.execute_script('window.scrollTo(0,0);')
      when :bottom
        def gaussian(mean, stddev)
          theta = 2 * Math::PI * rand
          rho = Math.sqrt(-2 * Math.log(1 - rand))
          scale = stddev * rho
          x = mean + scale * Math.cos(theta)
          y = mean + scale * Math.sin(theta)
          return x, y
        end
        height = @session.evaluate_script('document.body.scrollHeight')
        new_height = gaussian(height - 1000, 1000).min.to_i
        @session.execute_script("window.scrollTo(0,#{new_height});")
      else
        raise ''
      end

      logger __method__, "#{kind}: #{new_height}"
      execute_sleep
    end

    def Fill(arg, with:, clear: true)
      elm = Find(arg)
      if clear
        elm.native.clear
        sleep 2
      end
      elm.native.send_key(with)

      logger __method__, arg, with
      execute_sleep
    end

    def Submit(arg)
      @session.find(arg).native.submit()
      logger __method__, arg
      execute_sleep
    end

    def HasText? text
      (!!Nokogiri::HTML.parse(@session.html).at("*:contains('#{text}')")).tap do |bool|
        logger __method__, "#{text}=#{bool}"
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