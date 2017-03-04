require 'bundler/setup'

require 'capybara'
require 'capybara/dsl'
require 'csv'
require 'pry'
require 'uri'

#require 'selenium/webdriver'
#Capybara.register_driver :selenium do |app|
  #Selenium::WebDriver.for :firefox
#end
#Capybara.current_driver = :selenium

require 'capybara/poltergeist'
Capybara.current_driver = :poltergeist

include Capybara::DSL

visit "https://dc-directory.hqnet.usda.gov/dlsnew/phone.aspx"

departments = all('#cboAgency option').map(&:text)

FileUtils.mkdir_p 'data'

CSV.open 'data/directory.csv', 'w' do |csv|
  departments.each do |department|
    next if department == ''

    select department
    click_button 'Locate'

    first_row = true
    all('#header tr', visible: true).each do |row|
      begin
        if first_row
          csv << ['Last Name', 'First Name', 'MI', 'Phone Number', 'Agency', 'Room', 'Building', 'Department']
          first_row = false
        else
          tds = row.all('td')
          if tds.length > 1
            csv << tds.map(&:text).map(&:strip).reject { |td| td.length == 0 } + [department]
          end
        end
      rescue => e
        binding.pry
      end
    end
  end
end


