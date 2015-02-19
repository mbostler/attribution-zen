Given(/^a performance day for a portfolio$/) do
  @day = Attribution::Day.new
end

When(/^I create the data file for that performance day$/) do
  @data_file = @day.create_data_file
end

Then(/^the data file should have a header line$/) do
  @text = File.read @data_file.path
  expect(@text.split.first).to match(/CUSIP\s*\,\s*TICKER/)
end

Then(/^the data file should have one data line per security$/) do
  expect(@text.split.size).to eq(@day.security_days.size+1)
end