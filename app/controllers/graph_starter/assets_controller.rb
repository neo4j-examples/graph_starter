module GraphStarter
  class AssetsController < ::GraphStarter::ApplicationController
    def home
    end

    def index
      @assets = asset_set
    end

    def search
      regexp = Regexp.new('.*' + params[:query].gsub(/\s+/, '.*') + '.*', 'i')
      assets = asset_set { |scope| scope.where(title: regexp) }
      results_data = assets.map do |asset|
        {
          title: asset.title,
          url: asset_path(id: asset, model_slug: asset.class.model_slug),
          image: images? && asset.first_image_source && asset.first_image_source.url || nil
        }.reject {|_, v| v.nil? }
      end

      render json: {results: results_data}.to_json
    end

    def asset_set
      associations = []
      associations << :images if images?
      associations << model_class.category_association if model_class.category_association

      scope = model_class_scope
      scope = yield scope if block_given?

      scope = scope.limit(50)

      if associations.present?
        scope.query_as(:s).with(:s).proxy_as(model_class_scope.model, :s).with_associations(*associations)
      else
        scope
      end
    end

    def show
      @asset = asset

      render file: 'public/404.html', status: :not_found, layout: false if !@asset
    end

    def edit
      @asset = asset

      render file: 'public/404.html', status: :not_found, layout: false if !@asset
    end

    def update
      @asset = asset
      @asset.update(params[:book])

      redirect_to action: :edit
    end

    def asset
      model_class_scope.find(params[:id])
    end

    def images?
      model_class_scope.has_images?
    end

    def model_class_scope
      @model_class_scope = if defined?(current_user)
        model_class.authorized_for(current_user)
      else
        model_class.all
      end
    end
  end
end
