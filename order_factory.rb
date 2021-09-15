class OrderFactory
  include Utils

  def call(date, contact, products)
    order_date = date.to_time + rand(OrderConstants::ONE_DAY)
    event_date = nil
    order_id = generate_order_id
    statuses = statuses_sample
    coupons =  coupons_sample
    amount = calculate_amount(products, coupons)
    additional_fields = build_additional_fields(contact)

    statuses.map do |status|
      event_date = event_date.nil? ? order_date : event_date + rand(OrderConstants::ONE_DAY)
      {
        order_id: order_id,
        status: status,
        amount: amount,
        products: products,
        coupons: coupons,
        email: contact[:email],
        order_date: order_date,
        event_date: event_date,
        billing: contact[:billing_address],
      }.merge(additional_fields)
    end
  end

  private

  def generate_order_id
    @order_id ||= 99
    @order_id += 1
    "##{@order_id}"
  end

  def build_additional_fields(_contacts)
    {}
  end

  def statuses_sample
    OrderConstants::STATUSE_OPTIONS[0..rand(OrderConstants::STATUSE_OPTIONS.size)]
  end

  def coupons_sample
    OrderConstants::COUPONS_OPTIONS[rand(OrderConstants::COUPONS_OPTIONS.size)]
  end

  def calculate_amount(products, _coupons)
    # add variant to the sum
    products.sum { |product| (product[:price] * product[:quantity]) }.round(2)
  end
end
