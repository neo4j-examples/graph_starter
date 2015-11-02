module GraphStarter
  module ApplicationHelper
    def asset_path(asset)
      super(id: asset, model_slug: asset.class.model_slug)
    end

    def engine_view(&b)
       yield eval("__FILE__.gsub(Rails.root.to_s, GraphStarter::Engine.root.to_s)",b.binding) 
    end

    def render_body(asset, model_slug)
      views = Dir.glob(Rails.root.join("app/views/#{model_slug}/_body.html.*"))

      partial_path = views.present? ? "#{model_slug}/body" : 'body'

      render partial: partial_path, locals: {asset: asset}
    end

    def present_asset(object)
      yield(AssetPresenter.new(object, self)) if block_given?
    end
  end
end
