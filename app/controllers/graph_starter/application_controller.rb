module GraphStarter
  class ApplicationController < ::ApplicationController

    protected

    def model_class
      @model_slug = params[:model_slug]
      @model_slug.classify.constantize
    end
  end
end
