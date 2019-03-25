class PassengerTrain < Train
  def attachable_wagon?(wagon)
    wagon.is_a?(PassengerWagon)
  end
end
