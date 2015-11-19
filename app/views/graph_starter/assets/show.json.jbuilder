@asset.class.authorized_properties(current_user).each do |property|
  json.set! property.name, @asset.read_attribute(property.name)
end


json.associations do
  @asset.class.authorized_associations.each do |name, association|
    value = case association.type
            when :has_many
              @asset.send(name).to_a
            when :has_one
              @asset.send(name)
            else
              fail "Invalid association: #{association.inspect}"
            end

    json.set! name, value
  end
end

