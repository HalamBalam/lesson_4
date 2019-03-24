require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'passenger_train'
require_relative 'cargo_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'

def choose_element(elements)
  loop do
    elements.each.with_index(1) do |element, index|
      puts "#{index}-\"#{element.description}\""
    end

    index = gets.chomp.to_i - 1
    if index >= 0 && !elements[index].nil?
      return elements[index]  
    end
  end
end

# Секция Станции
def section_stations(stations)
  loop do
    puts "\nВыберите станцию для просмотра поездов или создайте новую (+)"

    stations.each.with_index(1) do |station, index|
      puts "#{index}-\"#{station.name}\""
    end
    puts "0-Назад"

    action = gets.chomp
    break if action == "0"  
  
    if action == "+"
      puts "Введите название станции"
      name = gets.chomp
      stations << Station.new(name)
    else
      index = action.to_i - 1

      if index >= 0 && !stations[index].nil?
        station = stations[index]

        if station.trains.empty? 
          puts "На станции \"#{station.name}\" нет поездов"
        else
          puts "Позда на станции \"#{station.name}\":"
          station.trains.each { |train| puts train.description }  
        end
      end
    end
  end
end


# Секция Поезда
def create_train
  loop do
    puts "Выберите тип поезда"
    puts "1-Грузовой"
    puts "2-Пассажирский"
    train_type = gets.chomp.to_i

    if [1, 2].include?(train_type)
      puts "Введите номер поезда"
      train_number = gets.chomp
      return train_type == 1 ? CargoTrain.new(train_number) : PassengerTrain.new(train_number)
    end
  end  
end

def attach_wagons(train, trains_wagons)
  puts "Введите количество прицепляемых вагонов"
  wagon_count = gets.chomp.to_i
  wagon_count.times do
    if train.type == :cargo
      wagon = CargoWagon.new
    else
      wagon = PassengerWagon.new
    end
    train.attach_wagon(wagon)
    trains_wagons[train] = [] if trains_wagons[train].nil?
    trains_wagons[train] << wagon
  end 
end

def detach_wagons(train, trains_wagons)
  puts "Введите количество отцепляемых вагонов"
  wagon_count = gets.chomp.to_i
  trains_wagons[train] = [] if trains_wagons[train].nil?

  wagon_count.times.with_index(1) do |index|
    wagon = trains_wagons[train][index]
    break if wagon.nil?
    train.detach_wagon(wagon)
    trains_wagons[train][index] = nil    
  end 

  trains_wagons[train].compact!
end

def set_route(train, routes)
  if routes.empty?
    puts "Для начала создайте маршрут"
    return
  end

  puts "Выберите маршрут"
  route = choose_element(routes)

  train.set_route(route)
end

def section_trains(trains, trains_wagons, routes)
  loop do
    puts "\nВыберите поезд для дальнейших действий или создайте новый (+)"

    trains.each.with_index(1) do |train, index|
      puts "#{index}-\"#{train.description}\""
    end

    puts "0-Назад"

    action = gets.chomp
    break if action == "0"

    if action == "+"
      trains << create_train
    else

      index = action.to_i - 1
      if index >= 0 && !trains[index].nil?
        train = trains[index]

        loop do
          puts "\nВыберите действие с поездом \"#{train.description}\""
          puts "1-Прицепить вагоны"
          puts "2-Отцепить вагоны"
          puts "3-Назначить маршрут"
          puts "4-Отправиться на следующую станцию"
          puts "5-Вернуться на предыдущую станцию"
          puts "0-Назад"

          action_with_train = gets.chomp.to_i
          break if action_with_train.zero?

          if action_with_train == 1
            attach_wagons(train, trains_wagons)  
          elsif action_with_train == 2
            detach_wagons(train, trains_wagons)
          elsif action_with_train == 3
            set_route(train, routes)
          elsif action_with_train == 4
            train.go_forward
          elsif action_with_train == 5
            train.go_back
          end
        end
      end

    end

  end
end


# Секция Маршруты
def create_route(stations)
  if stations.size < 2
    puts "Для начала создайте минимум 2 станции"
    return
  end

  puts "Выберите начальную станцию"
  start = choose_element(stations)

  puts "Выберите конечную станцию"
  finish = choose_element(stations)

  Route.new(start, finish) unless start == finish
end

def add_station(route, stations)
  puts "Выберите добавляемую станцию"
  station = choose_element(stations)

  route.add_station(station) unless station.nil?
end

def delete_station(route)
  if route.stations.size < 3
    puts "У маршрута должно быть больше двух станций"
    return
  end

  puts "Выберите удаляемую станцию"
  station = choose_element(route.stations[1, route.stations.size - 2])

  route.delete_station(station) unless station.nil?
end

def section_routes(routes, stations)
  loop do
    puts "\nВыберите маршрут для дальнейших действий или создайте новый (+)"

    routes.each.with_index(1) do |route, index|
      puts "#{index}-\"#{route.description}\""
    end

    puts "0-Назад"

    action = gets.chomp
    break if action == "0"

    if action == "+"
      route = create_route(stations)
      routes << route unless route.nil?
    else
      index = action.to_i - 1
      if index >= 0 && !routes[index].nil?
        route = routes[index]

        loop do
          puts "\nВыберите действие с маршрутом \"#{route.description}\""
          puts "1-Добавить станцию"
          puts "2-Удалить станцию"
          puts "0-Назад"

          action_with_route = gets.chomp.to_i
          break if action_with_route.zero?

          if action_with_route == 1
            add_station(route, stations)  
          elsif action_with_route == 2
            delete_station(route)   
          end
        end
      end
    end  
  end
end


stations = []
trains = []
trains_wagons = {}
routes = []

loop do
  puts "\nВыберите раздел: \n1-Станции \n2-Поезда \n3-Маршруты \n0-Выход"

  action = gets.chomp.to_i
  break if action.zero?

  case action
  when 1
    section_stations(stations)
  when 2
    section_trains(trains, trains_wagons, routes)
  when 3
    section_routes(routes, stations)
  end
end
