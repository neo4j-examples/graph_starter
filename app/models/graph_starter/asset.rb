require 'graph_starter/query_authorizer'

module GraphStarter
  class Asset
    include Neo4j::ActiveNode
    self.mapped_label_name = 'Asset'

    include Neo4j::Timestamps

    include Authorizable

    property :title
    validates :title, presence: true

    property :summary

    property :view_count, type: Integer

    property :private, type: Boolean, default: false

    #has_many :in, :creators, type: :CREATED, model_class: :User

    has_many :in, :viewers, rel_class: :View, model_class: :User

    SecretSauceRecommendation = Struct.new(:asset, :score)

    def body
    end

    IMAGE_MODELS = []
    def self.has_images
      GraphStarter::Asset::IMAGE_MODELS << self
      has_many :out, :images, type: :HAS_IMAGE, model_class: '::GraphStarter::Image'
    end

    def self.has_images?
      GraphStarter::Asset::IMAGE_MODELS.include?(self)
    end

    def first_image_source
      images.first && images.first.source
    end 

    def self.category_association
      @category_association
    end

    def self.category_association=(association_name)
      @category_association = association_name
    end

    def categories
      if self.class.category_association
        send(self.class.category_association)
      else
        []
      end
    end


    def self.for_query(query)
      all.where(title: /.*#{query}.*/i)
    end

    def secret_sauce_recommendations
      query_as(:source)
        .match('source-[:HAS_CATEGORY]->(category:Category)<-[:HAS_CATEGORY]-(asset:Asset)')
        .break
        .optional_match('source<-[:CREATED]-(creator:User)-[:CREATED]->asset')
        .break
        .optional_match('source<-[:VIEWED]-(viewer:User)-[:VIEWED]->asset')
        .limit(5)
        .order('score DESC')
        .pluck(
          :asset,
          '(count(category) * 2) +
           (count(creator) * 4) +
           (count(viewer) * 0.1) AS score').map do |other_asset, score|
        SecretSauceRecommendation.new(other_asset, score)
      end
    end

    def name
      title
    end

    def as_json(_options = {})
      {self.class.model_slug =>
        {id: id,
         title: title,
         name: title,
         images: images.map {|image| image.source.url },
         model_slug: self.class.model_slug}
       }
    end

    def self.descendants
      Rails.application.eager_load! if Rails.env == 'development'
      Neo4j::ActiveNode::Labels._wrapped_classes.select { |klass| klass < self }
    end

    def self.model_slug
      name.tableize
    end

    def self.properties
      attributes.keys - Asset.attributes.keys
    end

    def self.authorized_for(user)
      require 'graph_starter/query_authorizer'

      ::GraphStarter::QueryAuthorizer.new(all(:asset).categories(:category, nil, optional: true))
        .authorized_query([:asset, :category], user)
        .with('DISTINCT asset AS asset')
        .proxy_as(self, :asset)
    end

    def self.authorized_properties(user)
      authorized_properties_query(user).pluck(:property)
    end

    def self.authorized_properties_and_levels(user)
      authorized_properties_query(user).pluck(:property, :level)
    end

    def self.authorized_properties_query(user)
      query = property_name_and_uuid_and_ruby_type_query
              .merge(model: {Model: {name: name}})
              .on_create_set(model: {private: false})
              .break
              .merge('model-[:HAS_PROPERTY]->(property:Property {name: property_name})')
              .on_create_set(property: {private: false})
              .on_create_set('property.uuid = uuid, property.ruby_type = ruby_type')
              .with(:property)

      ::GraphStarter::Property # rubocop:disable Lint/Void
      QueryAuthorizer.new(query).authorized_query(:property, user)
    end

    def self.property_name_and_uuid_and_ruby_type_query
      properties_and_uuids_and_ruby_types = properties.map do |property|
        [property, SecureRandom.uuid, self.attributes[property][:type]]
      end

      Neo4j::Session.current.query
        .with('{array} AS array')
        .unwind('array AS row')
        .params(array: properties_and_uuids_and_ruby_types)
        .with('row[0] AS property_name, row[1] AS uuid, row[2] AS ruby_type')
    end

    def self.authorized_associations
      associations.except(*Asset.associations.keys + [:images])
    end

    def self.icon_class
      'bookmark'
    end
  end
end