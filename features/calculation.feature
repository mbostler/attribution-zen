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
	
  Scenario Outline: Calculating cumulative security-level returns
    Given a portfolio whose first security returned <r1_1>, <r1_2>, and <r1_3>
    And whose second security returned <r2_1>, <r2_2>, and <r2_3>
    And whose first security's weights were <w1_1>, <w1_2>, and <w1_3>
    And whose second security's weights were <w2_1>, <w2_2>, and <w2_3>
	When I ask the program to calculate performance
	Then I should see security-level returns of <r1_t> and <r2_t>
	And I should see security-level contributions of <c1_t> and <c2_t>
	And I should see a listing of portfolio return <result>
	
	Examples:
	|r1_1|r1_2|r1_3|r2_1|r2_2|r3_3|w1_1|w1_2|w1_3|w2_1|w2_2|w2_3|r1_t|r2_t|c1_t|c2_t|result|
