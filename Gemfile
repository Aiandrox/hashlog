source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'bootsnap', require: false
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'puma', '~> 4.3'
gem 'rails', '~> 5.2.5'
gem 'sprockets', '~> 3.7.2' # 4.0だとassetsがないときにエラーが発生するため
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'webpacker'

# 日本語化
gem 'enum_help'
gem 'rails-i18n'
# 機能
gem 'active_model_serializers'
gem 'administrate'
gem 'banken'
gem 'config'
gem 'pagy'
gem 'sorcery'
# 定期実行
gem 'whenever', require: false
# 外部API
gem 'twitter'
# seedファイル
gem 'seed-fu'
# slack通知
gem 'exception_notification'
gem 'slack-notifier'

group :development, :test do
  gem 'bullet'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails_best_practices'
  gem 'rubocop', require: false
  # RSpec
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  # モック
  gem 'vcr', require: false
  gem 'webmock', require: false
end
