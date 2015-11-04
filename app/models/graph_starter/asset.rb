require 'graph_starter/query_authorizer'

module GraphStarter
  class Asset
    include Neo4j::ActiveNode
    self.mapped_label_name = 'Asset'

    include Neo4j::Timestamps

    include Authorizable

    property :summary

    if GraphStarter.configuration.user_class
      #has_many :in, :creators, type: :CREATED, model_class: GraphStarter.configuration.user_class

      has_many :in, :viewer_sessions, rel_class: :'GraphStarter::View', model_class: 'GraphStarter::Session'

      has_many :in, :rated_by_user, rel_class: :'GraphStarter::Rating', model_class: GraphStarter.configuration.user_class
    end


    SecretSauceRecommendation = Struct.new(:asset, :score)

    def self.has_images
      @has_images = true
      has_many :out, :images, type: :HAS_IMAGE, model_class: '::GraphStarter::Image'
    end

    def self.has_image
      @has_image = true
      has_one :out, :image, type: :HAS_IMAGE, model_class: '::GraphStarter::Image'
    end

    def self.has_images?
      !!@has_images
    end

    def self.has_image?
      !!@has_image
    end

    def self.image_association
      if has_images?
        :images
      elsif has_image?
        :image
      end
    end

    def first_image
      if self.class.has_images?
        images.first
      elsif self.class.has_image?
        image
      end
    end

    def image_array
      if self.class.has_images?
        images.to_a
      elsif self.class.has_image?
        [image].compact
      end
    end

    def first_image_source_url
      first_image && first_image.source_url
    end 

    def self.category_association(association_name = nil)
      if association_name.nil?
        @category_association
      else
        fail "Cannot declare category_association twice" if @category_association.present?
        name = association_name.to_sym
        fail ArgumentError, "Association #{name} is not defined" if associations[name].nil?
        @category_association = name
      end
    end

    def categories
      if self.class.category_association
        send(self.class.category_association)
      else
        []
      end
    end


    def self.enumerable_property(property_name, values)
      fail "values needs to be an Array, was #{values.inspect}" if !values.is_a?(Array)

      validates :status, inclusion: {in: values}

      enumerable_property_values[self.name.to_sym] ||= {}
      enumerable_property_values[self.name.to_sym][property_name.to_sym] ||= values
    end

    def self.enumerable_property_values_for(property_name)
      enumerable_property_values[self.name.to_sym] && 
        enumerable_property_values[self.name.to_sym][property_name.to_sym]
    end

    def self.enumerable_property_values
      @enumerable_property_values ||= {}
    end


    def self.rated
      @rated = true
    end

    def self.rated?
      !!@rated
    end


    def self.name_property(property_name = nil)
      if property_name.nil?
        name_property(default_name_property) if @name_property.nil?

        @name_property
      else
        fail "Cannot declare name_property twice" if @name_property.present?
        name = property_name.to_sym
        fail ArgumentError, "Property #{name} is not defined" if !attributes.key?(name.to_s)
        @name_property = name

        validates name, presence: true
        index name
      end
    end

    def self.name_property?(property_name)
      @name_property && @name_property.to_sym == property_name.to_sym
    end

    def self.default_name_property
      (%w(name title) & attributes.keys)[0].tap do |property|
        if property.nil?
          fail "No name_property defined for #{self.name}!"
        end
      end
    end

    def safe_title
      sanitizer = Rails::Html::WhiteListSanitizer.new

      sanitizer.sanitize(title, tags: %w(b em i strong))
    end

    def self.body_property(property_name = nil)
      if property_name.nil?
        body_property(default_name_property) if @body_property.nil?

        @body_property
      else
        fail "Cannot declare body_property twice" if @body_property.present?
        name = property_name.to_sym
        fail ArgumentError, "Property #{name} is not defined" if !attributes.key?(name.to_s)
        @body_property = name
      end
    end

    def self.body_property?(property_name)
      @body_property && @body_property.to_sym == property_name.to_sym
    end

    def self.default_body_property
      if @body_property.nil? && !attributes.key?('body')
        fail "No body_property defined for #{self.name}!"
      end

      body_property || 'body'
    end


    def self.display_properties(*property_names)
      if property_names.empty?
        @display_properties
      else
        @display_properties = property_names.map(&:to_sym)
      end
    end

    def self.display_property?(property_name)
      display_properties.nil? || display_properties.include?(property_name.to_sym)
    end


    def rating_level_for(user)
      rating = rating_for(user)
      rating && rating.level
    end

    def rating_for(user)
      rated_by_user(nil, :rating).where(uuid: user.uuid).pluck(:rating)[0]
    end

    def method_missing(method_name, *args, &block)
      if [:name, :title].include?(method_name.to_sym)
        self.class.send(:define_method, method_name) do
          read_attribute(self.class.name_property)
        end

        send(method_name)
      elsif method_name.to_sym == :body
        self.class.send(:define_method, method_name) do
          read_attribute(self.class.body_property)
        end

        send(method_name)
      else
        super
      end
    end


    def self.search_properties(*array)
      if array.empty?
        @search_properties || [name_property]
      else
        @search_properties = array
      end
    end

    def self.for_query(query)
      where_clause = self.search_properties.map do |property|
        fail "Invalid property: #{property}" if attributes[property].nil?
        "asset.#{property} =~ {query}"
      end.join(' OR ')

      query_string = query.strip.gsub(/\s+/, '.*')
      all(:asset).where(where_clause).params(query: "(?i).*#{query_string}.*")
    end

    def secret_sauce_recommendations
      user_class = GraphStarter.configuration.user_class
      return [] if user_class.nil? # Should fix this later

      user_class = (user_class.is_a?(Class) ? user_class : user_class.to_s.constantize)
      user_label = user_class.mapped_label_name

      query_as(:source)
        .match('source-[:HAS_CATEGORY]->(category:Category)<-[:HAS_CATEGORY]-(asset:Asset)')
        .break
        .optional_match("source<-[:CREATED]-(creator:#{user_label})-[:CREATED]->asset")
        .break
        .optional_match("source<-[:VIEWED]-(viewer:#{user_label})-[:VIEWED]->asset")
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

    def as_json(_options = {})
      {self.class.model_slug =>
        {id: id,
         title: title,
         name: title,
         model_slug: self.class.model_slug}
       }.tap do |result|
         result[:images] = images.map {|image| image.source.url } if self.class.has_images?
         result[:image] = image.source_url if self.class.has_image? && image
       end
    end

    def views
      @views ||= viewer_sessions.rels
    end

    def total_view_count
      views.map(&:count).sum
    end

    def unique_view_count
      views.size
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

      if category_association
        ::GraphStarter::QueryAuthorizer.new(all(:asset).send(category_association, :category, nil, optional: true))
          .authorized_query([:asset, :category], user)
          .with('DISTINCT asset AS asset')
          .proxy_as(self, :asset)
      else
        ::GraphStarter::QueryAuthorizer.new(all(:asset))
          .authorized_query(:asset, user)
          .with('DISTINCT asset AS asset')
          .proxy_as(self, :asset)
      end
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
        type = self.attributes[property][:type]
        type = type.name if type.is_a?(Class)
        [property, SecureRandom.uuid, type]
      end

      Neo4j::Session.current.query
        .with('{array} AS array')
        .unwind('array AS row')
        .params(array: properties_and_uuids_and_ruby_types)
        .with('row[0] AS property_name, row[1] AS uuid, row[2] AS ruby_type')
    end

    def self.authorized_associations
      associations.except(*Asset.associations.keys + [:images, :image])
    end

    def self.icon_class
      GraphStarter.configuration.icon_classes[self.name.to_sym]
    end
  end
end
