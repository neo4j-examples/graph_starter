module GraphStarter
  module ApplicationHelper
    def asset_path(asset)
      # graph_starter.asset_path({id: asset.slug, model_slug: asset.class.model_slug}.merge(options))
      # Switched to string for performance
      "/#{asset.class.model_slug}/#{asset.slug}"
    end

    def engine_view(&b)
       yield eval("__FILE__.gsub(Rails.root.to_s, GraphStarter::Engine.root.to_s)",b.binding) 
    end

    def render_body(asset, model_slug)
      views = Dir.glob(Rails.root.join("app/views/#{model_slug}/_body.html.*"))

      partial_path = views.present? ? "#{model_slug}/body" : '/graph_starter/assets/body'

      render partial: partial_path, locals: {asset: asset}
    end

    def present_asset(object)
      yield(AssetPresenter.new(object, self)) if block_given?
    end

    def app_user_is_admin?
      current_user && current_user.respond_to?(:admin?) && current_user.admin?
    end

    def app_user
      defined?(:current_user) ? current_user : nil
    end

    def missing_image_tag
      @missing_image_tag ||= image_tag 'missing.png'
    end

    # I know, right?
    def asset_icon(asset, image = (image_unspecified = true; nil))
      image_url = if !image_unspecified
                    image.source.url if image.present?
                  elsif (asset.class.has_images? || asset.class.has_image?) && asset.first_image_source_url.present?
                    asset.first_image_source_url
                  end

      if image_url
        image_tag image_url, class: 'ui avatar image'
      else
        content_tag :i, '', class: [asset.class.icon_class || 'folder', 'large', 'icon']
      end
    end
  end
end
