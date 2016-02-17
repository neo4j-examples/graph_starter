module GraphStarter
  class CategoriesController < ApplicationController
    def show
      @category = category

      render json: @category
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def category
      Asset.find_by(slug: slug)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def slug
      params.require(:slug)
    end
  end
end
