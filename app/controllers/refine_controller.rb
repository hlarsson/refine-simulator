require 'refineSimulator'

class RefineController < ApplicationController
  def index
  end

  def run
	sim = Simulator.new

	strategy = RefiningStrategy.new(
		param[:miragesLow]..param[:miragesHigh], 
		param[:tienkangsLow]..param[:tienkangsHigh], 
		param[:tishasLow]..param[:tishasHigh])
	@config = RunConfiguration.new(
		param[:startLevel], param[:targetLevel], param[:nrOfRuns], strategy)
	@results, @time = sim.run(@config)
  end
end
