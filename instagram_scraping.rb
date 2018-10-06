# require 'nokogiri'
# require 'mechanize'
# require 'pry'
require 'selenium-webdriver'
require 'time'
require 'pry'
FOLLOWERS = 100000


# @agent = Mechanize.new
# @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
#
# page = @agent.get('https://www.instagram.com/accounts/login/?force_classic_login')
# @agent.page.forms[0]['username'] = 'apurvamayank'
# @agent.page.forms[0]['password'] = 't1e2s3t4'
# @agent.page.forms[0].submit
#
# doc = Nokogiri.parse(@agent.get('https://www.instagram.com/tonysvisuals').body)
#
# p doc
Selenium::WebDriver::Chrome.driver_path='/usr/lib/chromium-browser/chromedriver'
options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
driver = Selenium::WebDriver.for(:chrome, options: options)
driver.get('https://www.instagram.com/accounts/login/')
username = driver.find_element(name: 'username')
username.send_keys('')
password = driver.find_element(name: 'password')
password.send_keys('')
password.submit

driver.get('https://instagram.com/tonysvisuals')
driver.title

# Below to find number of followers
followers = driver.find_elements(class: 'g47SY')[1].attribute('title').gsub(',','').to_i

videos = driver.find_elements(:class, 'Nnq7C').take(2).map do |div|
  div.find_elements(:tag_name, 'a')#.attribute('href')
end

videos.flatten.each do |video|
  p video.attribute('href')
  new_driver = Selenium::WebDriver.for(:chrome, options: options)
  new_driver.get(video.attribute('href'))
  p new_driver.find_element(class: 'HbPOm').find_element(tag_name: 'span').text.gsub(',','').to_i
  p new_driver.find_element(tag_name: 'time').attribute('datetime')
  new_driver.quit
end


# Click to get suggestions

 driver.find_element(class: 'mLCHD').click
suggestions = driver.find_elements(class: 'nOA-W').map do |suggestion|
  suggestion.attribute('href')
end


class Instagram
  FOLLOWERS = 100000
  def initialize
    @driver = set_driver
  end

  def set_driver
    Selenium::WebDriver::Chrome.driver_path='/usr/lib/chromium-browser/chromedriver'
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.get('https://www.instagram.com/accounts/login/')
    username = driver.find_element(name: 'username')
    username.send_keys('')
    password = driver.find_element(name: 'password')
    password.send_keys('')
    password.submit
    driver.get('https://instagram.com/tonysvisuals')
    driver
  end

  def followers_count
    count = @driver.find_elements(class: 'g47SY')[1].attribute('title').gsub(',','').to_i
    p "Count of followers is #{count}"
    suggested_account if count > FOLLOWERS
    count
  end

  def profile_link
    @driver.current_url
  end

  def video_list
    videos = @driver.find_elements(:class, 'Nnq7C').take(2).map do |div|
      div.find_elements(:tag_name, 'a')#.attribute('href')
    end
  end

  def video
    link = []
    video_list.flatten.each do |video|
      p video.attribute('href')
      Selenium::WebDriver::Chrome.driver_path='/usr/lib/chromium-browser/chromedriver'
      options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
      new_driver = Selenium::WebDriver.for(:chrome, options: options)
      new_driver.get(video.attribute('href'))
      views = new_driver.find_element(class: 'HbPOm').find_element(tag_name: 'span').text.gsub(',','').to_i
      post_time = new_driver.find_element(tag_name: 'time').attribute('datetime')
      time_spent = (Time.now.utc - Time.parse(post_time))/3600
      link << new_driver.current_url if required_video?(views)
      new_driver.quit
    end
    p 'List of required videos is below'
    puts link
  end

  def required_video?(views)
    true if views >= 6 * followers_count
  end

  def potential_viral?(time_spent, views)
    true if time_spent < 2 && views > 100_000
  end

  def suggested_account
    @driver.find_element(class: 'mLCHD').click rescue nil
    new_account = @driver.find_element(class: 'nOA-W').attribute('href')
    @driver.get(new_account)
    followers_count
  end

  def quit_driver
    @driver.quit
  end

end

insta_scrape = Instagram.new

10.times do
  insta_scrape.profile_link
  insta_scrape.followers_count
  insta_scrape.video
  insta_scrape.suggested_account
end

# driver.quit
