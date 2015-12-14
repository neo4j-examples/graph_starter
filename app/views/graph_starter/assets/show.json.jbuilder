@asset.class.authorized_properties(current_user).each do |property|
  next if @asset.class.hidden_json_properties.include?(property.name.to_sym)

  json.set! property.name, @asset.read_attribute(property.name)
end

@asset.class.json_methods.each do |method_name|
  json.set! method_name, @asset.send(method_name)
end

json.summary @asset.summary

json.image_urls @asset.reload.image_array.map(&:source_url)

json.categories @asset.categories

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

