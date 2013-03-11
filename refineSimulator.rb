class RefiningStrategy
	def initialize(miragesRange, tienkangsRange, tishasRange)
		@strategy = { :mirages => miragesRange, :tienkangs => tienkangsRange, :tishas => tishasRange}
	end

	def getAidForLvl(lvl)
		@strategy.each_pair do |aid, lvlRange|
			if (lvlRange.include? lvl) 
				return aid
			end
		end
	end

	def to_s
		"mirages: " + @strategy[:mirages].to_s + ", tienkangs: " + @strategy[:tienkangs].to_s + ", tishas: " + @strategy[:tishas].to_s
	end
end

class RefineSimulator
	@@refineRates = [
		{ :mirages => 0.5, :tienkangs => 0.65, :tishas => 0.535}, #+1
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+2
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+3
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+4
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+5

		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+6
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+7
		{ :mirages => 0.3, :tienkangs => 0.45, :tishas => 0.335}, #+8
		{ :mirages => 0.25, :tienkangs => 0.40, :tishas => 0.285}, #+9
		{ :mirages => 0.2, :tienkangs => 0.35, :tishas => 0.235}, #+10

		{ :mirages => 0.12, :tienkangs => 0.27, :tishas => 0.155}, #+11
		{ :mirages => 0.05, :tienkangs => 0.20, :tishas => 0.085}, #+12
	]

	def self.refineRates
		@@refineRates
	end

	def run(startLvl=0, targetLvl, nrOfRuns, strategy)
		# nrOfRuns.times { results.update(run(startLvl, targetLvl, strategy, SingleRunResult.new(startLvl))) }
		runOnce(startLvl, targetLvl, strategy, SingleRunResult.new(startLvl))
	end

	def runOnce(currentLvl, targetLvl, strategy, result)
		if (currentLvl == targetLvl)
			result
		else
			newLvl, aid = refine(currentLvl, strategy)
			runOnce(newLvl, targetLvl, strategy, result.update(newLvl, aid))
		end
	end

	def refine(lvl, strategy)
		aid = strategy.getAidForLvl(lvl)
		puts "aid used: " + aid.to_s
		if (rand < RefineSimulator.refineRates[lvl][aid])
			refineSucceeded(lvl, aid)
		else
			refineFailed(lvl, aid)
		end
	end

	def refineSucceeded(lvl, aid)
		puts "Success! +" + lvl.to_s + " -> " + "+" + (lvl + 1).to_s
		return lvl + 1, aid
	end

	def refineFailed(lvl, aid)
		case aid
		when :mirages
			puts "Fail! +" + lvl.to_s + " -> " + "+0"
			return 0, aid
		when :tienkangs
			puts "Fail! +" + lvl.to_s + " -> " + "+0"
			return 0, aid
		when :tishas
			puts "Fail! +" + lvl.to_s + " -> " + "+" + (lvl - 1).to_s
			return lvl - 1, aid
		end
	end

	def testStuff
		puts RefineSimulator.refineRates[8][:tienkangs]
		puts "+8 failed mir: " + refineFailed(8, :mirages).to_s
		puts "+8 failed tien: " + refineFailed(8, :tienkangs).to_s
		puts "+8 failed tishas: " + refineFailed(8, :tishas).to_s
	end
end

class SingleRunResult
	def initialize(startLvl, mirages = 0, tienkangs = 0, tishas = 0)
		@lvl = startLvl
		@mirages = mirages
		@tienkangs = tienkangs
		@tishas = tishas
	end

	def update(newLvl, aid)
		mirages = @mirages + 1
		tienkangs = @tienkangs + (aid == :tienkangs ? 1 : 0)
		tishas = @tishas + (aid == :tishas ? 1 : 0)
		SingleRunResult.new(newLvl, mirages, tienkangs, tishas)
	end

	def to_s
		"lvl: " + @lvl.to_s + ", mirages: " + @mirages.to_s + ", tienkangs: " + @tienkangs.to_s + ", tishas: " + @tishas.to_s
	end
end

result = SingleRunResult.new(5)
#puts result
#puts result.update(6, :tienkangs)

sim = RefineSimulator.new
#sim.testStuff


strategy = RefiningStrategy.new(0..2, 3..4, 5..11)
#10.times { puts sim.refine(7, strategy) }
puts sim.run(6, 7, 1, strategy)
#sim.run(5)