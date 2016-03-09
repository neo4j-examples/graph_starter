module GraphStarter
  class Configuration
    attr_writer :user_class

    attr_accessor :menu_models, :icon_classes, :scope_filters, :editable_properties, :default_image_style

    def initialize
      @icon_classes = {}
      @scope_filters = {}
      @editable_properties = {}
    end

    def user_class
      @user_class || (:User if defined?(::User))
    end

    def validation_errors
      {}.tap do |errors|
        if !(@menu_models.respond_to?(:each) || @menu_models.nil?)
          errors[:menu_models] = 'should be enumerable or nil'
        end

        if !@icon_classes.is_a?(Hash)
          errors[:icon_classes] = 'should be a Hash'
        end

        if !@editable_properties.is_a?(Hash)
          errors[:editable_properties] = 'should be a Hash'
        end

        if !@scope_filters.is_a?(Hash)
          errors[:scope_filters] = 'should be a Hash'
        end
      end
    end
  end
end

module GraphStarter
  CONFIG = Configuration.new

  def self.configure(config_hash = nil)
    if config_hash.nil?
      yield CONFIG
    else
      config_hash.each do |key, value|
        CONFIG.send("#{key}=", value)
      end
    end

    errors = CONFIG.validation_errors

    fail "GraphStarter validation errors: #{errors.inspect}" if errors.size > 0
  end

  def self.configuration
    CONFIG
  end
end

