module GraphStarter
  module ApplicationHelper
    def asset_path(asset)
      super(id: asset, model_slug: asset.class.model_slug)
    end

    def engine_view(&b)
       yield eval("__FILE__.gsub(Rails.root.to_s, GraphStarter::Engine.root.to_s)",b.binding) 
    end    
  end
end
