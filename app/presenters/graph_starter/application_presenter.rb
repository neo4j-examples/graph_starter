module GraphStarter
  class ApplicationPresenter < SimpleDelegator
    def initialize(object, view)
      @object, @view = object, view
      super(@object)
    end

    def h
      @view
    end
  end
end
