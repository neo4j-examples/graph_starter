module GraphStarter
  class ApplicationController < ::ApplicationController

    before_action :load_session_node

    def load_session_node
      session.delete('this_key_should_never_exist') # Make sure we have a session

      @session_node_thread = Thread.new do
        Session.merge(session_id: session.id).tap do |session_node|
          if current_user && session_node.user.nil?
            session_node.user = current_user
          end

          previous_session_id = session['previous_session_id']
          if previous_session_id && previous_session_id != session.id
            session_node.previous_session = Session.find_by(session_id: previous_session_id)
          end
        end
      end

      session['previous_session_id'] = session.id
    end

    def session_node
      puts 'joining...'
      @session_node_thread.join.value
    end

    protected

    def model_class
      @model_slug = params[:model_slug]
      @model_slug.classify.constantize
    end
  end
end
