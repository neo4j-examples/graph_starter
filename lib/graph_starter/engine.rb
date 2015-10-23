require 'neo4jrb_paperclip'
require 'semantic-ui-sass'

require 'neo4j-core'
require 'neo4j'
require 'neo4j/railtie'
require 'neo4j/rake_tasks'
require 'slim-rails'

module GraphStarter
  class Engine < ::Rails::Engine
    isolate_namespace GraphStarter

    config.autoload_paths << File.expand_path("../../", __FILE__)

    config.neo4j._active_record_destroyed_behavior = true

    config.assets.precompile += %w(
      missing.png

      graph_starter/ember_apps/permissions_modal.js
      graph_starter/ember_apps/user_list_dropdown.js
    )
  end
end
