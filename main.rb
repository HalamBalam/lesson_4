require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'passenger_train'
require_relative 'cargo_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'

class Main
  
  MAIN_MENU              = ['Станции', 'Поезда', 'Маршруты']
  STATIONS_MENU          = ['Создать станцию', 'Показать поезда на станции']
  TRAINS_MENU            = ['Создать поезд', 'Выбрать поезд для дальнейших действий']
  ACTION_WITH_TRAIN_MENU = ['Прицепить вагоны', 'Отцепить вагоны', 'Назначить маршрут',
                            'Отправиться на следующую станцию', 'Вернуться на предыдущую станцию']
  TRAIN_TYPES_MENU       = ['Грузовой', 'Пассажирский']
  ROUTES_MENU            = ['Создать маршрут', 'Выбрать маршрут для дальнейших действий']
  ACTION_WITH_ROUTE_MENU = ['Добавить станцию', 'Удалить станцию']

  def run
    @stations = []
    @trains = []
    @trains_wagons = {}
    @routes = []

    loop do
      show_menu(MAIN_MENU)

      case gets.to_i
      when 0 then break
      when 1 then stations_menu
      when 2 then trains_menu
      when 3 then routes_menu
      end
    end  
  end

  private

  def show_menu(menu, show_exit = true)
    puts
    menu.each.with_index(1) do |item, index|
      puts "#{index}-#{item}"
    end
    puts "0-Выход" if show_exit
  end

  def show_collection(elements)
    elements.each.with_index(1) do |element, index|
      puts "#{index}-\"#{element.description}\""
    end  
  end

  def choose_element(elements)
    return if elements.empty?
    loop do
      show_collection(elements)

      index = gets.chomp.to_i - 1
      if index >= 0 && !elements[index].nil?
        return elements[index]  
      end
    end
  end

  def create_station
    puts "Введите название станции"
    name = gets.chomp
    station = Station.new(name)
    puts "Создана станция: \"#{station.description}\""
    @stations << station
  end

  def show_station_trains
    station = choose_element(@stations)
    return unless station
    if station.trains.empty?
      puts "На станции \"#{station.description}\" нет поездов"
    else
      puts "Поезда на станции \"#{station.description}\":"
      show_collection(station.trains)
    end
  end

  def stations_menu
    loop do
      show_menu(STATIONS_MENU)
      case gets.to_i
      when 0 then break
      when 1 then create_station
      when 2 then show_station_trains
      end
    end
  end

  def create_train
    loop do
      show_menu(TRAIN_TYPES_MENU, false)
      train_type = gets.chomp.to_i

      next unless [1, 2].include?(train_type)

      puts "Введите номер поезда"
      train_number = gets.chomp

      train = train_type == 1 ? CargoTrain.new(train_number) : PassengerTrain.new(train_number)
      puts "Создан поезд: \"#{train.description}\""
      @trains << train
      break
    end  
  end

  def attach_wagons(train)
    puts "Введите количество прицепляемых вагонов"
    wagon_count = gets.chomp.to_i
    wagon_count.times do
      wagon = train.is_a?(CargoTrain) ? CargoWagon.new : PassengerWagon.new
      train.attach_wagon(wagon)
      @trains_wagons[train] = [] if @trains_wagons[train].nil?
      @trains_wagons[train] << wagon
    end 
  end

  def detach_wagons(train)
    puts "Введите количество отцепляемых вагонов"
    wagon_count = gets.chomp.to_i
    @trains_wagons[train] = [] if @trains_wagons[train].nil?

    wagon_count.times.with_index(1) do |index|
      wagon = @trains_wagons[train][index]
      break if wagon.nil?
      train.detach_wagon(wagon)
      @trains_wagons[train][index] = nil    
    end 

    @trains_wagons[train].compact!
  end

  def set_route(train)
    if @routes.empty?
      puts "ОШИБКА: Для начала создайте маршрут"
      return
    end

    puts "Выберите маршрут"
    route = choose_element(@routes)
    train.set_route(route)
  end

  def action_with_train_menu
    train = choose_element(@trains)
    return unless train

    loop do
      puts "\nВыберите действие с поездом \"#{train.description}\""
      show_menu(ACTION_WITH_TRAIN_MENU)

      case gets.to_i
      when 0 then break
      when 1 then attach_wagons(train)
      when 2 then detach_wagons(train)
      when 3 then set_route(train)
      when 4 then train.go_forward
      when 5 then train.go_back
      end
    end
  end

  def trains_menu
    loop do
      show_menu(TRAINS_MENU)
      case gets.to_i
      when 0 then break
      when 1 then create_train
      when 2 then action_with_train_menu
      end
    end
  end

  def create_route
    if @stations.size < 2
      puts "ОШИБКА: Для начала создайте минимум 2 станции"
      return
    end

    puts "Выберите начальную станцию"
    start = choose_element(@stations)

    puts "Выберите конечную станцию"
    finish = choose_element(@stations)

    return if start == finish
    route = Route.new(start, finish)
    puts "Создан маршрут: \"#{route.description}\""
    @routes << route
  end

  def add_station(route)
    puts "Выберите добавляемую станцию"
    station = choose_element(@stations)

    route.add_station(station) unless station.nil?
  end

  def delete_station(route)
    if route.stations.size < 3
      puts "ОШИБКА: У маршрута должно быть больше двух станций"
      return
    end

    puts "Выберите удаляемую станцию"
    station = choose_element(route.stations[1, route.stations.size - 2])

    route.delete_station(station) unless station.nil?
  end

  def action_with_route_menu
    route = choose_element(@routes)
    return unless route

    loop do
      puts "\nВыберите действие с маршрутом \"#{route.description}\""
      show_menu(ACTION_WITH_ROUTE_MENU)

      case gets.to_i
      when 0 then break
      when 1 then add_station(route)
      when 2 then delete_station(route)
      end
    end  
  end

  def routes_menu
    loop do
      show_menu(ROUTES_MENU)
      case gets.to_i
      when 0 then break
      when 1 then create_route
      when 2 then action_with_route_menu
      end
    end
  end

end

main = Main.new
main.run
