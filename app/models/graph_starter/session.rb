module GraphStarter
  class Session
    include Neo4j::ActiveNode
    self.mapped_label_name = 'Session'

    property :session_id, constraint: :unique

    if GraphStarter.configuration.user_class
      has_one :out, :user, type: :FOR_USER, model_class: GraphStarter.configuration.user_class
    end

    has_one :out, :previous_session, type: :REPLACES, model_class: :'GraphStarter::Session'
  end
end

