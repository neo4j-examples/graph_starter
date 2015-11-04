class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    message = validation_message(value)

    record.errors.add attribute, message if message
  end

  def validation_message(value)
    match = value.to_s.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)

    if match || value == '::1'
      if !value.split('.').all? { |segment| segment.to_i.in?(0..255) }
        'segments must be between 0 and 255'
      end
    else
      'must match IP address pattern'
    end
  end
end
