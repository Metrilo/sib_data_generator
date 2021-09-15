class OrdersGenerator
  include Utils

  def initialize(start_date:, end_date:, orders_factory:, writers:, multiple_files: false)
    @start_date = start_date
    @end_date = end_date
    @orders_factory = orders_factory
    @writers = writers
    @products_db = ProductsGenerator.new.call
    @multiple_files = multiple_files
  end

  def call
    ret_contacts = generate_contacts(OrderConstants::TOTAL_RET_CONTACTS)

    orders_batch = []
    batch_id = build_batch_id(@start_date)
    (@start_date.to_date..@end_date.to_date).each do |date|
      if @multiple_files && new_batch?(date, batch_id)
        @writers.each { |w| w.write(orders_batch, batch_id) }
        orders_batch = []
        batch_id = build_batch_id(date)
      end

      new_contacts_orders_count = rand(0..OrderConstants::NEW_CONSTACTS_RATIO / 10).floor.to_i
      ret_contacts_orders_count = rand(0..OrderConstants::RET_CONSTACTS_RATIO / 10).floor.to_i
      new_contacts_for_orders = generate_contacts(new_contacts_orders_count)
      ret_contacts_for_orders = take_random_contacts(ret_contacts, ret_contacts_orders_count)

      orders_batch.append(*generate_orders(date, new_contacts_for_orders))
      orders_batch.append(*generate_orders(date, ret_contacts_for_orders))
    end

    @writers.each { |w| w.write(orders_batch, batch_id) }
  end

  private

  def new_batch?(date, batch_id)
    build_batch_id(date) != batch_id
  end

  def build_batch_id(date)
    date.strftime('%Y-%m')
  end

  def generate_orders(date, contacts)
    contacts.map do |contact|
      @orders_factory.call(date, contact, products_sample)
    end.flatten
  end

  def products_sample
    products_count_in_order = rand(1..3)
    (0..products_count_in_order).to_a.map do
      product_db = @products_db[rand(@products_db.size)]
      product = {
        id: product_db[:id],
        price: product_db[:price],
        quantity: rand(1..2)
      }
      product[:variant] = product_db[:variants][rand(1..product_db[:variants].size)] if product_db[:variants]
      product
    end
  end

  def take_random_contacts(contacts, count)
    contacts.sample(count)
  end

  def generate_contacts(contacts_count)
    contacts = []
    contacts_count.times do
      contacts << {
        id: generate_contact_id,
        email: Faker::Internet.email,
        uid: generate_letters(32),
        billing_address: generate_billing_address
      }
    end

    contacts
  end

  def generate_billing_address
    {
      address: Faker::Address.street_address.gsub("'", ''),
      city: Faker::Address.city.gsub("'", ''),
      country_code: Faker::Address.country_code,
      phone: Faker::PhoneNumber.cell_phone,
      postcode: Faker::Address.postcode,
      payment_method: ['Pay Pal', 'Visa', 'Master card', 'Ca$h'].sample,
      region: Faker::Address.state
    }
  end

  def generate_contact_id
    @contact_id ||= 0
    @contact_id += 1
    @contact_id
  end
end
