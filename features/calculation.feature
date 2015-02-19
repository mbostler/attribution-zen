Feature: Calculation

  Scenario Outline: Calculating cumulative portfolio-level returns
    Given a portfolio with a first day's return of <r1>
	And a second day's return of <r2>
	And a third day's return of <r3>
	When I ask the program to calculate performance
	Then portfolio's cumulative performance should be <result>
	
	Examples:
	|  r1  |  r2  |  r3  | result |
	|   1.05  |   1.08  |  1.15  |  1.3041 |
	|  0.94  |   1.08  |  0.95  | 0.96444 |
	
  Scenario: Calculating cumulative security-level returns
  	Given a portfolio defined by the calculation data file
	When I ask the program to calculate performance
	Then I should see cumulative security-level performance that matches the data file
	And I should see cumulative security-level contribution that matches the data file
