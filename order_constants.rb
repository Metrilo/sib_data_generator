module OrderConstants
  NEW_CONSTACTS_RATIO = 35.0
  RET_CONSTACTS_RATIO = 65.0
  ONE_DAY = 60 * 60 * 24 - 1
  ORGANIZATION_ID = 1900010713334
  TOTAL_RET_CONTACTS = 1000

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

  STATUSE_OPTIONS = %w[placed processing paid canceled].freeze
end
