require 'yaml'
require 'selenium-webdriver'
require 'time'
require 'pry'
require 'csv'

class InstagramProfile
  @@profiles = File.file?('suggestions.csv') ? File.read('suggestions.csv').split : []
  def initialize
    @driver = set_driver
  end

  def selenium_config
    Selenium::WebDriver::Chrome.driver_path='/usr/lib/chromium-browser/chromedriver'
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.get('https://www.instagram.com/accounts/login/')
    driver
  end

  def insta_login(driver)
    data = YAML.safe_load(File.read('creds.yml'))
    username = driver.find_element(name: 'username')
    username.send_keys(data['instagram_creds']['username'])
    password = driver.find_element(name: 'password')
    password.send_keys(data['instagram_creds']['password'])
    password.submit
    puts "Login page #{driver.title}-#{driver.current_url}"
    driver
  end

  def set_driver
    driver = selenium_config
    insta_login(driver)
  end

  def required_profile?(profile_url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    new_driver = Selenium::WebDriver.for(:chrome, options: options)
    new_driver.get(profile_url)
    new_driver.get(profile_url)
    count = new_driver.find_elements(class: 'g47SY')[1].attribute('title').gsub(',','').to_i
    new_driver.quit
    true if count.between?(25_000, 100_000)
  end

  def suggestions_required?
    a = @driver.find_element(class: '_6CZji') rescue nil
    a.nil? ? true : false
  end

  def account_suggestions
    @@profiles.each do |profile|
      suggestion_list(profile)
    end
  end

  def suggestion_list(profile)
    @driver.get(profile)
    click_for_suggestions if suggestions_required?
    10.times do
      suggestions = suggestion
      suggestions = suggestions - @@profiles
      suggestion_empty?(suggestions)
    end
  end

  def suggestion
    @driver.find_elements(class: 'nOA-W').map do |suggestion|
      begin
        p suggestion.attribute('href')
        suggestion.attribute('href') if required_profile?(suggestion.attribute('href'))
      rescue StandardError => error
        puts "The error was #{error}"
      end
    end
  end

  def suggestion_empty?(suggestions)
    if suggestions.compact.empty?
      @driver.find_element(class: '_6CZji').click rescue nil
    else
      suggestions.compact.each do |suggestion|
        @@profiles << suggestion
        generate_csv(suggestion)
      end
    end
  end

  def click_for_suggestions
    @driver.find_element(class: 'mLCHD').click rescue nil
  end

  def retry_suggestions
    puts "Inside retry suggestions"
    click_for_suggestions
    @driver.find_element(class: '_6CZji').click
    click_for_suggestions
  end

  def generate_csv(suggestion)
    file = 'suggestions.csv'
    CSV.open(file, 'ab', write_headers: false) do |writer|
      puts "Before writing CSV #{suggestion}"
      writer << [suggestion]
    end
  end

  def reset_profile
    @@profiles = File.file?('suggestions.csv') ? File.read('suggestions.csv').split : []
  end

  def quit
    @driver.quit
  end

  def set_to_login
    @driver.get('')
  end
end

driver = InstagramProfile.new
driver.account_suggestions
