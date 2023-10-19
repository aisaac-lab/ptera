module Ptera
  module Methods
    def visit(url, ensure_has: nil, max_retry_count: 3)
      encoded_url = Addressable::URI.encode(url)

      @session.visit encoded_url

      unless ensure_has.nil?
        try = 0
        until has?(ensure_has)
          @session.visit encoded_url
          try += 1
          raise "error url: #{url}, ensure_has: #{ensure_has}" if max_retry_count < try
        end
      end

      logger __method__, url
      execute_sleep
    end

    def find(*args, **options)
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

    def has?(*args, **option)
      !!find(*args, maybe: true, **option)
    end

    def click(*args, **options)
      find(*args, **options).click

      # begin
      #   element.click
      # rescue Selenium::WebDriver::Error::ElementNotInteractableError
      #   element.evaluate_script('this.click()')
      # end

      logger __method__, args.first
      execute_sleep
    end

    def click_maybe(*args, **options)
      if @session.find_all(*args, **options).count == 1
        click(*args, **options)
      else
        logger __method__, "#{args.first} is not found"
      end
    end

    def scroll_to(kind)
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

    def fill(arg, with:, clear: true)
      elm = find(arg)
      if clear
        elm.native.clear
        sleep 2
      end
      elm.native.send_key(with)

      logger __method__, arg, with
      execute_sleep
    end

    def has_text?(text)
      (!!Nokogiri::HTML.parse(@session.html).at("*:contains('#{text}')")).tap do |bool|
        logger __method__, "#{text}=#{bool}"
      end
    end
  end
end