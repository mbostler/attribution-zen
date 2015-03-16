Given(/^I want to run a portfolio performance report for a single day$/) do
  portfolio_name = "bodhi"
  @date = Date.civil(2015, 2, 19)
  @portfolio = Attribution::Portfolio.where( :name  => portfolio_name ).first_or_create!
  @report = Attribution::Report.new :portfolio  => @portfolio,
                                    :start_date => @date,
                                    :end_date   => @date
end

Given(/^the portfolio day's performance hasn't been run before$/) do
  @portfolio.clear_data_on @data
end

When(/^I ask the report to calculate$/) do
  pending "wait"
  # @report.calculate
end

Then(/^the holding data for the portfolio day should be saved$/) do
  expect( @portfolio.holdings_on( @date ) ).to_not be_empty
end

Then(/^the transaction data for the portfolio day should be saved$/) do
  expect( @portfolio.transactions_on( @date ) ).to_not be_empty
end