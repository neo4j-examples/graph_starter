module GraphStarter
  class AssetsController < ::GraphStarter::ApplicationController
    def home
    end

    def index
      @all_assets = asset_set(:asset, nil)
      @assets = asset_set.to_a
    end

    def search
      assets = asset_set { |scope| scope.for_query(params[:query]) }
      results_data = assets.map do |asset|
        description = model_class.search_properties.map do |property|
          "<b>#{property.to_s.humanize}:</b> #{asset.read_attribute(property)}"
        end.join("<br>")

        {
          title: asset.title,
          url: asset_path(id: asset, model_slug: asset.class.model_slug),
          description: description,
          image: asset.first_image_source_url
        }.reject {|_, v| v.nil? }.tap do |result|
          model_class.search_properties.each do |property|
            result[property] = asset.read_attribute(property)
          end
        end
      end

      # INCLUDE SEARCH QUERY PROPERTIES IN RESULT!!!

      render json: {results: results_data}.to_json
    end

    def asset_set(var = :asset, limit = 50)
      associations = []
      associations << model_class.image_association
      associations << model_class.category_association
      associations.compact!

      scope = model_class_scope(var)
      scope = yield scope if block_given?

      scope = scope.limit(limit)

      scope = if associations.present?
                scope.query_as(var).with(var).proxy_as(model_class, var).with_associations(*associations)
              else
                scope
              end

      asset_scope_filter ? asset_scope_filter.call(scope) : scope
    end

    def show
      @asset = asset

      View.record_view(@session_node,
                       @asset,
                       browser_string: request.env['HTTP_USER_AGENT'],
                       ip_address: request.remote_ip)

      render file: 'public/404.html', status: :not_found, layout: false if !@asset
    end

    def edit
      @asset = asset

      render file: 'public/404.html', status: :not_found, layout: false if !@asset
    end

    def update
      @asset = asset
      @asset.update(params[params[:model_slug].singularize])

      redirect_to action: :edit
    end

    def new
      @asset = model_class.new
    end

    def create
      @asset = model_class.create(params[params[:model_slug].singularize])

      if @asset.persisted?
        redirect_to action: :show, id: @asset.id
      else
        puts '@asset.errors.messages', @asset.errors.messages.inspect
        flash[:error] = @asset.errors.messages.to_a.map {|pair| pair.join(' ') }.join(' / ')
        redirect_to :back
      end
    end

    def destroy
      asset.destroy

      redirect_to action: :index
    end

    def rate
      if current_user
        rating = asset.rating_for(current_user)
        rating ||= Rating.create(from_node: current_user, to_node: asset)

        new_rating = params[:new_rating].to_i
        new_rating = nil if new_rating.zero?
        rating.update_attribute(:level, new_rating)

        render json: rating
      else
        render json: {}
      end
    end

    def asset
      model_class_scope.find(params[:id])
    end

    def model_class_scope(var = :asset)
      #@model_class_scope = if defined?(current_user)
      #  model_class.authorized_for(current_user)
      #else
      #  model_class.all(var)
      #end

      @model_class_scope ||= model_class.all(var)
    end

    private

    def asset_scope_filter
      GraphStarter.configuration.scope_filters[model_class.name.to_sym]
    end

  end
end
