Given(/^a performance day for a portfolio$/) do
  portfolio = Attribution::Portfolio.where( name: "+&smcomp" ).first_or_create
  @day = Attribution::Day.create! :date => Date.civil(2015, 4, 1), :portfolio_id => portfolio.id
end

When(/^I create the data file for that performance day$/) do
  @data_file = @day.create_data_file
end

Then(/^the data file should have a header line$/) do
  @text = File.read @data_file.path
  expect(@text.split.first).to match(/CUSIP/i)
  expect(@text.split.first).to match(/SYMBOL/i)
end

Then(/^the data file should have one data line per security$/) do
  text_lines = @text.split("\n").reject(&:blank?)
  expect(text_lines.size).to eq(@day.security_days.size+1)
end