module GraphStarter
  class Property
    include Neo4j::ActiveNode
    self.mapped_label_name = 'Property'

    include Authorizable

    property :name, index: :exact
    property :ruby_type, index: :exact
    property :created_at
    property :updated_at

    has_one :in, :model, type: :HAS_PROPERTY, model_class: '::GraphStarter::Model'

    def attribute_object
      model.ruby_model.attributes[name]
    end
  end
end
