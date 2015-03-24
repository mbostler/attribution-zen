class Date
	def trading_day?
		return false unless (1..5).cover? self.wday
		return false if Holiday.on? self
		true
	end
	
	def previous_trading_day
	  day = self.clone - 1.day
	  day -= 1.day until day.trading_day?
	  day
	end
	alias_method :prev_trading_day, :previous_trading_day

	def next_trading_day
	  day = self.clone + 1.day
	  day += 1.day until day.trading_day?
	  day
	end

end