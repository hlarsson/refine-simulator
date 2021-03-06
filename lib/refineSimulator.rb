class Simulator
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

	def run(config)
		startTime = Time.now
		results = SimulationResults.new
		config.nrOfRuns.times { 
			results = results.update(
				runOnce(
					config.startLvl, config.targetLvl, config.strategy, 
					config.cost, SingleRunResult.new(config.startLvl, config.cost))) }
		endTime = Time.now
		return results, (endTime - startTime)
	end

	def runOnce(startLvl, targetLvl, strategy, cost, result)
		result = SingleRunResult.new(startLvl, cost)
		while (result.lvl != targetLvl)
			newLvl, aid = refine(result.lvl, strategy)
			result = result.update(newLvl, aid)
		end
		result
	end

	def refine(lvl, strategy)
		aid = strategy.getAidForLvl(lvl)
		if (rand < @@refineRates[lvl][aid])
			refineSucceeded(lvl, aid)
		else
			refineFailed(lvl, aid)
		end
	end

	def refineSucceeded(lvl, aid)
		return lvl + 1, aid
	end

	def refineFailed(lvl, aid)
		case aid
		when :mirages
			return 0, aid
		when :tienkangs
			return 0, aid
		when :tishas
			return lvl - 1, aid
		end
	end
end

class RunConfiguration
	attr_accessor :startLvl, :targetLvl, :nrOfRuns, :strategy
	def initialize(startLvl, targetLvl, nrOfRuns, strategy, typeOfGear)
		@startLvl = startLvl
		@targetLvl = targetLvl
		@nrOfRuns = nrOfRuns
		@strategy = strategy
		@typeOfGear = typeOfGear
	end

	def cost
		case @typeOfGear
		when :weapon
			2
		when :g16
			5
		else
			1
		end
	end

	def to_s
		"start lvl: #{@startLvl}, target lvl: #{@targetLvl}," +
		"nr of runs: #{@nrOfRuns}, strategy: #{strategy}"
	end
end

class RefiningStrategy
	attr_accessor :ranges, :useTienkangs, :useTishas
	def initialize(useTienkangs, useTishas, tienkangsRange, tishasRange)
		@ranges = { 
			:tienkangs => (useTienkangs ? tienkangsRange : 13..13),
			:tishas => (useTishas ? tishasRange : 13..13) 
		}
		@useTienkangs = useTienkangs
		@useTishas = useTishas
	end

	def getAidForLvl(lvl)
		@ranges.each_pair do |aid, lvlRange|
			if (lvlRange.include? lvl) 
				return aid
			end
		end
		:mirages
	end

	def to_s
		"tienkangs: #{@ranges[:tienkangs].to_s}, tishas: #{@ranges[:tishas].to_s}"
	end
end

class SimulationResults
	attr_accessor :worst, :best
	def initialize(nrOfRuns=0, worst=SingleRunResult.new(0, 1, 0, 0, 0), best=SingleRunResult.new(0, 1, 100000000, 100000000, 100000000), total=SingleRunResult.new(0, 0, 0, 0))
		@nrOfRuns = nrOfRuns
		@worst = worst
		@best = best
		@total = total
	end

	def update(singleRunResult)
		SimulationResults.new(
			@nrOfRuns + 1,
			SingleRunResult::worst(@worst, singleRunResult),
			SingleRunResult::best(@best, singleRunResult),
			@total.add(singleRunResult))
	end

	def avg
		SingleRunResult.new(@best.lvl, @cost, @total.mirages.to_f / @nrOfRuns, @total.tienkangs.to_f / @nrOfRuns, @total.tishas.to_f / @nrOfRuns)
	end

	def to_s
		"Best run: #{@best.to_s}\nWorst run: #{@worst.to_s}\nAvg run: #{avg.to_s}"
	end
end

class SingleRunResult
	attr_accessor :lvl, :mirages, :tienkangs, :tishas
	def initialize(startLvl, cost, mirages = 0, tienkangs = 0, tishas = 0)
		@lvl = startLvl
		@mirages = mirages
		@tienkangs = tienkangs
		@tishas = tishas
		@cost = cost
	end

	def update(newLvl, aid)
		mirages = @mirages + @cost
		tienkangs = @tienkangs + (aid == :tienkangs ? 1 : 0)
		tishas = @tishas + (aid == :tishas ? 1 : 0)
		SingleRunResult.new(newLvl, @cost, mirages, tienkangs, tishas)
	end

	def self.worst(run1, run2)
		run1.mirages > run2.mirages ? run1 : run2
	end

	def self.best(run1, run2)
		run1.mirages < run2.mirages ? run1 : run2
	end

	def add(singleRunResult)
		SingleRunResult.new(singleRunResult.lvl, @cost, @mirages + singleRunResult.mirages, @tienkangs + singleRunResult.tienkangs, @tishas + singleRunResult.tishas)
	end

	def to_s
		"lvl: #{@lvl.to_s}, mirages: #{@mirages.to_s}, tienkangs: #{@tienkangs.to_s}, tishas: #{@tishas.to_s}"
	end
end
