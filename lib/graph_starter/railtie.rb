module GraphStarter
  class Railtie < Rails::Railtie
    initializer 'neo4j.start', after: :load_config_initializers do |app|
      GraphStarter.configure(app.config.graph_starter.to_hash)
    end
  end
end

