class CargoTrain < Train
  def attachable_wagon?(wagon)
    wagon.is_a?(CargoWagon)
  end
end
