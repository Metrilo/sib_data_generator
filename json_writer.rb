class JSONWriter
  def initialize(dir_name:)
    @dir_name = dir_name
  end

  def write(orders, btach_id)
    File.open("#{@dir_name}/orders_#{btach_id}_json", 'w') do |file|
      file.write({ result: parse_orders(orders) }.to_json)
    end
  end

  private

  def parse_orders(orders)
    orders.map do |order|
      {
        id: order[:order_id],
        status: order[:status],
        amount: order[:amount],
        createdAt: order[:order_date].rfc3339,
        updatedAt: order[:event_date].rfc3339,
        products: parse_products(order[:products]),
        email: order[:email],
        billing: parse_billing(order[:billing]),
        coupons: order[:coupons]
      }
    end
  end

  def parse_products(products)
    products.map do |product|
      parsed_product = {
        productId: product[:id],
        quantity: product[:quantity]
      }
      parsed_product[:variantId] = product[:variant][:id] if product[:variant]
      parsed_product
    end
  end

  def parse_billing(billing)
    {
      address: billing[:address],
      city: billing[:city],
      countryCode: billing[:country_code],
      phone: billing[:phone],
      postcode: billing[:postcode],
      paymentMethod: billing[:payment_method],
      region: billing[:region]
    }
  end
end
