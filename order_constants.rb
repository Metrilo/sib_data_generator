module OrderConstants
  ORGANIZATION_ID = 1900010713334

  ONE_DAY = 60 * 60 * 24 - 1

  NEW_CONSTACTS_AVG_PERCENTAGE = 35.0 / 100
  RET_CONSTACTS_AVG_PERCENTAGE = 65.0 / 100
  AVG_ORDERS_PER_DAY = 5
  AVG_ORDERS_PER_RET_CONTACTS = 5

  # rubocop:disable Style/WordArray
  COUPONS_OPTIONS = [
    ['15OFF'],
    ['30OFF'],
    ['SUMMER'],
    ['WINTER'],
    ['SUMMER', '15OFF'],
    ['WINTER', '15OFF'],
    ['WINTER', '30OFF']
  ].freeze
  # rubocop:enable Style/WordArray

  STATUSE_OPTIONS = %w[placed].freeze
  # STATUSE_OPTIONS = %w[placed processing paid canceled].freeze
end
