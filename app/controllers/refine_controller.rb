require 'refineSimulator'

class RefineController < ApplicationController
  @@runTable = {
    0 => 2000,
    1 => 2000,
    2 => 2000,
    3 => 2000,
    4 => 2000,
    5 => 2000,
    6 => 2000,
    7 => 2000,
    8 => 1000,
    9 => 100,
    10 => 10,
    11 => 1,
    12 => 1,
  }

  def index
  	@maxNrOfRuns = 
  		"{ 0 : #{@@runTable[0]}, " +
  		"  1 : #{@@runTable[1]}, " +
  		"  2 : #{@@runTable[2]}, " +
  		"  3 : #{@@runTable[3]}, " +
  		"  4 : #{@@runTable[4]}, " +
  		"  5 : #{@@runTable[5]}, " +
  		"  6 : #{@@runTable[6]}, " +
  		"  7 : #{@@runTable[7]}, " +
  		"  8 : #{@@runTable[8]}, " +
  		"  9 : #{@@runTable[9]}, " +
  		"  10 : #{@@runTable[10]}, " +
  		"  11 : #{@@runTable[11]}, " +
  		"  12 : #{@@runTable[12]} }"
  end

  def run
    errorMessages = []
    if (params[:useTienkangs])
      validateNumberInRange(params[:tienkangsLow], 0, 11, "Tienkangs have to be between 0 and 11.", errorMessages)
      validateNumberInRange(params[:tienkangsHigh], 0, 11, "Tienkangs have to be between 0 and 11.", errorMessages)
    end
    if (params[:useTishas])
      validateNumberInRange(params[:tishasLow], 0, 11, "Tishas have to be between 0 and 11.", errorMessages)
      validateNumberInRange(params[:tishasHigh], 0, 11, "Tishas have to be between 0 and 11.", errorMessages)
    end
    validateNumberInRange(params[:startLevel], 0, 12, "Start level has to be between 0 and 12.", errorMessages)
    validateNumberInRange(params[:targetLevel], 0, 12, "Target level has to be between 0 and 12.", errorMessages)
    validateNumberInRange(params[:nrOfRuns], 0, 100000, "Number of runs has to be between a positive integer.", errorMessages)
    validateNrOfRuns(params[:nrOfRuns], params[:targetLevel], "Number of runs can't exceed the max number of runs listed in the table.", errorMessages)

    if (errorMessages.length > 0)
      render :text => ValidationError.new(errorMessages).to_s
      return
    end

  	sim = Simulator.new

  	strategy = RefiningStrategy.new(
      params[:useTienkangs],
      params[:useTishas],
  		params[:tienkangsLow].to_i..params[:tienkangsHigh].to_i,
  		params[:tishasLow].to_i..params[:tishasHigh].to_i)

    typeOfGear = :armor
    if (params[:weapon])
      typeOfGear = :weapon
    elsif (params[:g16])
      typeOfGear = :g16
    end

  	@config = RunConfiguration.new(
  		params[:startLevel].to_i, params[:targetLevel].to_i, params[:nrOfRuns].to_i, strategy, typeOfGear)
  	@results, @time = sim.run(@config)
  end

  def validateNumberInRange(value, min, max, message, errorMessages)
    if (!(value.to_i.to_s == value && (min..max).include?(value.to_i)))
      errorMessages << message
    end
  end

  def validateNrOfRuns(nrOfRuns, targetLevel, message, errorMessages)
    if (nrOfRuns.to_i > @@runTable[targetLevel.to_i])
      errorMessages << message
    end
  end
end

class ValidationError
  def initialize(errorMessages)
    @errorMessages = errorMessages
  end

  def to_s
    message = "<h2>Error</h2><ul>"
    @errorMessages.each do |errorMessage|
      if (errorMessage != "")
        message += "<li>#{errorMessage}</li>"
      end
    end
    message += "</ul>"
  end
end