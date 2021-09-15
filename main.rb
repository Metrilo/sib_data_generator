require 'active_support/all'
require 'faker'

require_relative 'utils'
require_relative 'order_factory'
require_relative 'ch_factory'
require_relative 'order_constants'
require_relative 'json_writer'
require_relative 'ch_writer'
require_relative 'products_generator'
require_relative 'orders_generator'

WRITERS = {
  clickhouse: CHWriter,
  json: JSONWriter
}.freeze

FACTORIES = {
  clickhouse: CHFactory,
  json: OrderFactory
}.freeze

class Main
  def self.call(dir_name:, start_date:, end_date:, multiple_files:, multiple_inserts:)
    writers = []
    writers << WRITERS[:clickhouse].new(dir_name: dir_name, multiple_inserts: multiple_inserts)
    writers << WRITERS[:json].new(dir_name: dir_name)

    OrdersGenerator.new(
      start_date: start_date,
      end_date: end_date,
      orders_factory: FACTORIES[:clickhouse].new,
      writers: writers,
      multiple_files: multiple_files
    ).call
  end
end

# so, we generate same data every time we run the script
Faker::Config.random = Random.new(42)

# Configure these vars to change the outcome
start_date = Time.parse('2019-01-01')
end_date = Time.now.end_of_year
dir_name = 'data'
multiple_files = false
multiple_inserts = false # Clickhouse related
Main.call(
  dir_name: dir_name,
  start_date: start_date,
  end_date: end_date,
  multiple_files: multiple_files,
  multiple_inserts: multiple_inserts
)
