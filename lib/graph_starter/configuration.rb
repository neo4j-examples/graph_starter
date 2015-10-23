module GraphStarter
  class Configuration
    attr_writer :user_class

    def user_class
      @user_class || (:User if defined?(::User))
    end
  end
end

module GraphStarter
  CONFIG = Configuration.new

  def self.configure(config_hash = nil)
    if config_hash.nil?
      yield Configuration.new
    else
      config_hash.each do |key, value|
        CONFIG.send("#{key}=", value)
      end
    end
  end

  def self.configuration
    CONFIG
  end
end

