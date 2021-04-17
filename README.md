# Ptera

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ptera`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ptera'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ptera

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gogotanaka/ptera. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gogotanaka/ptera/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ptera project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gogotanaka/ptera/blob/master/CODE_OF_CONDUCT.md).


```ruby
require 'ptera'

key = :placeholder

Capybara.register_driver key do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['devtools.jsonview.enabled'] = false
  options = Selenium::WebDriver::Firefox::Options.new(profile: profile)
  Capybara::Selenium::Driver.new(app, options: options)
end

session = Capybara::Session.new(key)
driver = Ptera::Driver.new(session: session)
driver.instance_eval do
  Visit 'https://www.facebook.com/'
  Fill '#email', with: 'test@test.com'
  Fill '#pass', with: 'passw0rd'
  Click 'button[data-testid=royal_login_button]'
end

driver = Ptera::Driver.new(session: session, sleep_type: :short)
driver.instance_eval do
  Visit 'https://developers.google.com/speed/pagespeed/insights/?hl=JA'
  Fill 'input[name=url]', with: 'https://www.google.com/'
  Click 'div.main-submit'
  Find 'div.lh-gauge__percentage', wait: 20
end
```