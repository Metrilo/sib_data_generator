class CHFactory < OrderFactory
  EVENT_NAME = 'order'.freeze
  SIGN = 1

  def build_additional_fields(contact)
    {
      event_id: generate_letters(32),
      organization_id: OrderConstants::ORGANIZATION_ID,
      visitor_id: contact[:uid],
      contact_id: contact[:id],
      session_id: generate_letters(32),
      event_name: EVENT_NAME,
      sign: SIGN
    }
  end
end
