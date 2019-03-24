class Station
  attr_reader :name, :trains

  def initialize(name)
    @name = name
    @trains = []
  end

  def arrive(train)
    @trains << train
  end

  def depart(train)
    @trains.delete(train)
  end

  def trains_count(type)
    trains_by_type(type).size  
  end

  def description
    name
  end

  private
  
  def trains_by_type(type)
    trains.select { |train| train.type == type }
  end
end
