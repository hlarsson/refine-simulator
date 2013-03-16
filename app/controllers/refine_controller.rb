require 'refineSimulator'

class RefineController < ApplicationController
  def index
  	@maxNrOfRuns = 
  		"{ 0 : 1000, " +
  		"  1 : 1000, " +
  		"  2 : 1000, " +
  		"  3 : 1000, " +
  		"  4 : 1000, " +
  		"  5 : 1000, " +
  		"  6 : 1000, " +
  		"  7 : 1000, " +
  		"  8 : 100, " +
  		"  9 : 10, " +
  		"  10 : 10, " +
  		"  11 : 1, " +
  		"  12 : 1 }"
  end

  def run
	sim = Simulator.new

	strategy = RefiningStrategy.new(
		params[:tienkangsLow].to_i..params[:tienkangsHigh].to_i,
		params[:tishasLow].to_i..params[:tishasHigh].to_i)
	@config = RunConfiguration.new(
		params[:startLevel].to_i, params[:targetLevel].to_i, params[:nrOfRuns].to_i, strategy)
	@results, @time = sim.run(@config)
  end
end
