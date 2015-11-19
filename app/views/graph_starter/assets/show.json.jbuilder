@asset.class.authorized_properties(current_user).each do |property|
  json.set! property.name, @asset.read_attribute(property.name)
end


json.associations do
  @asset.class.authorized_associations.each do |name, association|
    json.set! name, @asset.send(name).to_a
  end
end

