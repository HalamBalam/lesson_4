class Route
  attr_reader :stations

  def initialize(start, finish)
    @stations = [start, finish]
  end

  def add_station(station)
    @stations.insert(-2, station) unless @stations.include?(station)
  end

  def delete_station(station)
    return if [@stations.first, @stations.last].include?(station)
    @stations.delete(station)
  end

  def print
    stations.each { |station| puts station.name }
  end

  def description
    start = stations.first.name
    finish = stations.last.name
    "#{start}-#{finish}, станций: #{stations.size}"
  end

end
