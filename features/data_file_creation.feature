Feature: Data File Creation

  Scenario: Creating a daily performance file
  	Given a performance day for a portfolio
	When I create the data file for that performance day
	Then the data file should have a header line
	And the data file should have one data line per security
