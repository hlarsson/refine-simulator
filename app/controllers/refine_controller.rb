require 'refineSimulator'

class RefineController < ApplicationController
  def index
  end

  def run
	sim = Simulator.new

	strategy = RefiningStrategy.new(
		params[:miragesLow].to_i..params[:miragesHigh].to_i,
		params[:tienkangsLow].to_i..params[:tienkangsHigh].to_i,
		params[:tishasLow].to_i..params[:tishasHigh].to_i)
	@config = RunConfiguration.new(
		params[:startLevel].to_i, params[:targetLevel].to_i, params[:nrOfRuns].to_i, strategy)
	@results, @time = sim.run(@config)
  end
end
