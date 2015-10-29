module GraphStarter
  class AssetPresenter < ApplicationPresenter
    def asset
      @object
    end

    def display_column_widths
      if main_column_exists?
        left_sidebar_exists? ? %w(three ten three) : [nil, 'thirteen', 'three']
      else
        ['eight', nil, 'eight']
      end
    end

    def left_sidebar_exists?
      @left_sidebar_exists ||= asset.class.authorized_associations.size > 2
    end

    def main_column_exists?
      @main_column_exists ||= asset.class.has_images? && asset.images.present? || asset.body.present?
    end
  end
end
