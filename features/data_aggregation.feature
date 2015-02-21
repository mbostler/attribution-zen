Feature: Data Aggregation

  Scenario: Saving portfolio data for one day
  	Given I want to run a portfolio performance report for a single day
	And the portfolio day's performance hasn't been run before
	When I ask the report to calculate
	Then the holding data for the portfolio day should be saved
	And the transaction data for the portfolio day should be saved
