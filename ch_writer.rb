class CHWriter
  INSERT_COMMAND = 'INSERT INTO events.order (
    event_name, Sign, event_id, organization_id, session_id, visitor_id,
    email_id, contact_id, event_date, order_id, order_status, order_amount,
    order_date, order_coupons, `products.product_id`, `products.variant_id`,
    `products.quantity`, billing_address, billing_city, billing_country_code,
    billing_region, billing_phone, billing_postcode, billing_payment_method) VALUES '.freeze

  CREATE_DATABASE_QUERY = 'CREATE DATABASE IF NOT EXISTS events;'.freeze

  CREATE_ORDER_TABLE_QUERY = "
      CREATE TABLE IF NOT EXISTS events.order
      (
          `organization_id` Int64 CODEC(ZSTD(1)),
          `contact_id` Int64 CODEC(ZSTD(1)),
          `email_id` String CODEC(ZSTD(1)),
          `session_id` String CODEC(ZSTD(1)),
          `visitor_id` String CODEC(ZSTD(1)),
          `event_name` String CODEC(ZSTD(1)),
          `event_source` String CODEC(ZSTD(1)),
          `tracking_source` String CODEC(ZSTD(1)),
          `event_date` DateTime64(3, 'UTC') CODEC(DoubleDelta, ZSTD(1)),
          `event_type` String CODEC(ZSTD(1)),
          `event_id` String CODEC(ZSTD(1)),
          `products.product_id` Array(String),
          `products.variant_id` Array(String),
          `products.quantity` Array(UInt8),
          `order_id` String CODEC(ZSTD(1)),
          `order_date` DateTime64(3, 'UTC') CODEC(DoubleDelta, ZSTD(1)),
          `order_amount` Float64 CODEC(ZSTD(1)),
          `order_status` String CODEC(ZSTD(1)),
          `order_coupons` Array(String) CODEC(ZSTD(1)),
          `billing_address` String CODEC(ZSTD(1)),
          `billing_city` String CODEC(ZSTD(1)),
          `billing_country_code` String CODEC(ZSTD(1)),
          `billing_region` String CODEC(ZSTD(1)),
          `billing_phone` String CODEC(ZSTD(1)),
          `billing_postcode` String CODEC(ZSTD(1)),
          `billing_payment_method` String CODEC(ZSTD(1)),
          `session_ip_address` String CODEC(ZSTD(1)),
          `session_city` String CODEC(ZSTD(1)),
          `session_region` String CODEC(ZSTD(1)),
          `session_country_code` String CODEC(ZSTD(1)),
          `session_timezone` String CODEC(ZSTD(1)),
          `session_latitude` Float64 CODEC(ZSTD(1)),
          `session_longitude` Float64 CODEC(ZSTD(1)),
          `session_user_agent_device` String CODEC(ZSTD(1)),
          `session_user_agent_browser` String CODEC(ZSTD(1)),
          `session_user_agent_version` String CODEC(ZSTD(1)),
          `session_user_agent_platform` String CODEC(ZSTD(1)),
          `session_source` String CODEC(ZSTD(1)),
          `session_origin` String CODEC(ZSTD(1)),
          `session_social` String CODEC(ZSTD(1)),
          `session_medium` String CODEC(ZSTD(1)),
          `session_referrer` String CODEC(ZSTD(1)),
          `session_source_and_medium` String CODEC(ZSTD(1)),
          `Sign` Int8 DEFAULT 1 CODEC(ZSTD(1)),
          `insertion_date` DateTime64(3, 'UTC') DEFAULT now() CODEC(DoubleDelta, ZSTD(1))
      )
      ENGINE = CollapsingMergeTree(Sign)
      PARTITION BY toYYYYMM(order_date)
      ORDER BY (organization_id,order_date,event_date,order_id,contact_id,event_id);
    ".freeze

  DEFAULT_RECORDS_COUNT = 1

  def initialize(dir_name:, multiple_inserts: false)
    @multiple_inserts = multiple_inserts
    @dir_name = dir_name
    @database_and_table_created = false
  end

  def write(orders, btach_id)
    File.open("#{@dir_name}/orders_#{btach_id}_ch", 'w') do |file|
      create_database_and_table(file) unless @database_and_table_created

      slice_count = @multiple_inserts ? DEFAULT_RECORDS_COUNT : orders.count
      orders.each_slice(slice_count) do |orders_slice|
        file.write(INSERT_COMMAND)
        file.write("#{parse_orders(orders_slice)}\n")
      end
    end
  end

  private

  def create_database_and_table(file)
    file.write(CREATE_DATABASE_QUERY)
    file.write("\n")
    file.write(CREATE_ORDER_TABLE_QUERY)
    @database_and_table_created = true
  end

  def print_single_q(array)
    "['#{array.join('\', \'')}']"
  end

  def print_time(time)
    time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def parse_products(products)
    parsed_products = {
      parent_products: [],
      variant_products: [],
      quantities: []
    }
    products.each do |product|
      parsed_products[:parent_products] << product[:id]
      parsed_products[:variant_products] << product.dig(:variant, :id) || ''
      parsed_products[:quantities] << product[:quantity]
    end

    parsed_products
  end

  def parse_orders(orders)
    orders.map do |order|
      products = parse_products(order[:products])
      billing = order[:billing]
      "('#{order[:event_name]}', #{order[:sign]}, '#{order[:event_id]}', #{order[:organization_id]}, '#{order[:session_id]}', '#{order[:visitor_id]}', '#{order[:email]}', #{order[:contact_id]}, '#{print_time(order[:event_date])}', '#{order[:order_id]}', '#{order[:status]}', #{order[:amount]}, '#{print_time(order[:order_date])}', #{print_single_q(order[:coupons])}, #{print_single_q(products[:parent_products])}, #{print_single_q(products[:variant_products])}, #{products[:quantities]}, '#{billing[:address]}', '#{billing[:city]}', '#{billing[:country_code]}', '#{billing[:region]}', '#{billing[:phone]}', '#{billing[:postcode]}', '#{billing[:payment_method]}')"
    end.join(', ')
  end
end
