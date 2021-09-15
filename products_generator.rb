class ProductsGenerator
  include Utils

  def initialize
    @products = []
  end

  def call
    20.times do
      @products << generate_single_products.merge(
        variants: [
          generate_single_variant,
          generate_single_variant,
          generate_single_variant
        ]
      )
    end

    10.times do
      @products << generate_single_products
    end

    @products
  end

  private

  def generate_single_products
    {
      id: "#{generate_numbers(5)}-#{generate_letters(5)}",
      name: Faker::Coffee.blend_name,
      price: generate_price
    }
  end

  def generate_single_variant
    {
      id: "#{generate_numbers(5)}-#{generate_letters(5)}",
      name: Faker::Coffee.variety,
      price: generate_price
    }
  end

  def generate_price
    rand(10.0..100.0).round(2)
  end
end
