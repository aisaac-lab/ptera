require 'capybara'
require 'selenium-webdriver'
require 'colorize'

module Ptera
  class Driver
    def initialize(session:)
      @session = session
    end

    def Visit(url, ensure_has: nil)
      encoded_url = Addressable::URI.encode(url)

      @session.visit encoded_url

      unless ensure_has.nil?
        try = 0
        until Has? ensure_has
          @session.visit encoded_url
          try += 1
          raise "error url: #{url}, ensure_has: #{ensure_has}" if try > 3
        end
      end

      logger __method__, url
      execute_sleep
    end

    private def Find(*args, **options)
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

    def WaitFor(wait_time = Capybara.default_max_wait_time, &block)
      Timeout.timeout(wait_time) do
        begin
          block.call
        rescue
          retry
        end
      end
    end

    def execute_sleep
      if ENV['SHORT_SLEEP'] == '1'
        sleep (3 + (0...4).to_a.sample)
      else
        sleep (8 + (0...4).to_a.sample)
      end
    end

    def logger(label, *bodies)
      object_id_colored = "[#{object_id}]".colorize(:green)
      label_colored = "[#{label}]".colorize(:light_red)

      puts "#{object_id_colored}#{label_colored} #{bodies.join(', ')} #{Time.now.strftime('%m/%d %H:%M:%S')}"
    end
  end
end