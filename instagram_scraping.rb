# require 'nokogiri'
# require 'mechanize'
# require 'pry'
require 'selenium-webdriver'

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

options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
driver = Selenium::WebDriver.for(:chrome, options: options)
driver.get('https://instagram.com/')
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
  p new_driver.find_element(class: 'vcOH2').find_element(tag_name: 'span').text.gsub(',','').to_i
  new_driver.quit
end


# Click to get suggestions

 driver.find_element(class: 'mLCHD').click
suggestions = driver.find_elements(class: 'nOA-W').map do |suggestion|
  suggestion.attribute('href')
end



# driver.quit
