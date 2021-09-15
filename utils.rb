module Utils
  def generate_letters(size)
    (0...size).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def generate_numbers(size)
    (0...size).map { (1..9).to_a[rand(9)] }.join
  end
end
