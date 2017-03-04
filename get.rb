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
  first_row = true

  departments.each do |department|
    next if department == ''

    select department
    click_button 'Locate'

    all('#header tr', visible: true).each do |row|
      begin
        if first_row
          csv << ['Last Name', 'First Name', 'MI', 'Phone Number', 'Agency', 'Room', 'Building', 'Department']
          first_row = false
        else
          next if row['class'] == 'header_row'

          tds = row.all('td')
          next unless tds.length > 1

          fields = tds.map(&:text).map(&:strip)
          fields.shift

          csv << fields + [department]
        end
      rescue => e
        binding.pry
      end
    end
  end
end


