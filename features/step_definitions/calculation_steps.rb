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

Given(/^a portfolio defined by the calculation data file$/) do
  data_file = File.join Rails.root, "features", "data", "calculation_data.yaml"
  @attribs = YAML.load File.read( data_file )
  puts "value of @attribs is: #{@attribs.inspect}"
  
  d1 = Date.civil( 2014, 2, 4 )
  d2 = d1 + 1
  d3 = d1 + 2
  
  @portfolio = Attribution::Portfolio.create!

  d1 = @portfolio.days.where( :date => d1 ).first_or_create
  d1.security_days.create!( { :cusip        => "A",
                      :weight       => @attribs["WA1"],
                      :performance  => @attribs["RA1"],
                      :contribution => @attribs["CA1"] })
  d1.security_days.create!( { :cusip        => "B",
                      :weight       => @attribs["WB1"],
                      :performance  => @attribs["RB1"],
                      :contribution => @attribs["CB1"] })
  d1.create_portfolio_day!( :performance => @attribs["TR1"] )

  d2 = d1.next_day
  d2.security_days.create!( { :cusip        => "A",
                      :weight       => @attribs["WA2"],
                      :performance  => @attribs["RA2"],
                      :contribution => @attribs["CA2"] })
  d2.security_days.create!( { :cusip        => "B",
                      :weight       => @attribs["WB2"],
                      :performance  => @attribs["RB2"],
                      :contribution => @attribs["CB2"] })
  d2.create_portfolio_day!( :performance => @attribs["TR2"] )

  d3 = d2.next_day
  d3.security_days.create!( { :cusip        => "A",
                      :weight       => @attribs["WA3"],
                      :performance  => @attribs["RA3"],
                      :contribution => @attribs["CA3"] })
  d3.security_days.create!( { :cusip        => "B",
                      :weight       => @attribs["WB3"],
                      :performance  => @attribs["RB3"],
                      :contribution => @attribs["CB3"] })
  d3.create_portfolio_day!( :performance => @attribs["TR3"] )

  @report = Attribution::Report.new :portfolio => @portfolio,
                                    :start_date => d1.date,
                                    :end_date => d3.date
  
  @report.calculate
end

Then(/^I should see cumulative security\-level performance that matches the data file$/) do
  expect(@report.security_results["A"][:performance]).to eq(@attribs["RAC"])
  expect(@report.security_results["B"][:performance]).to eq(@attribs["RBC"])  
end

Then(/^I should see cumulative security\-level contribution that matches the data file$/) do
  expect(@report.security_results["A"][:contribution]).to eq(@attribs["CAC"])
  expect(@report.security_results["B"][:contribution]).to eq(@attribs["CBC"])  
end