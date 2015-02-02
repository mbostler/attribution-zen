Given(/^a portfolio with a first day's return of (\d+\.\d+)$/) do |arg1|
  @portfolio = Attribution::Portfolio.new
  @portfolio.returns[0] = arg1
end

Given(/^a second day's return of (\d+\.\d+)$/) do |arg1|
  @portfolio.returns[1] = arg1
end

Given(/^a third day's return of (\-?\d+\.\d+)$/) do |arg1|
  @portfolio.returns[2] = arg1
end

When(/^I ask the program to calculate performance$/) do
  @output = @portfolio.calculate
end

Then(/^portfolio's cumulative performance should be (\-?\d+\.\d+)$/) do |arg1|
  num = Float( arg1 )
  expect( @portfolio.total_performance ).to eq( num )
end

Given(/^a portfolio with a first day's return of \-(\d+)$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see a listing of portfolio return \-(\d+)\.(\d+)$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end