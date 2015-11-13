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
      @left_sidebar_exists ||= authorized_associations.size > 4
    end

    def main_column_exists?
      @main_column_exists ||= images_present? || body_present? || associations_in_body?
    end

    def images_present?
      @images_present ||= ((asset.class.has_images? || asset.class.has_image?) && asset.image_array.present?)
    end

    def body_present?
      @body_present ||= asset.body.present?
    end

    def associations_in_body?
      @associations_in_body ||= !images_present? && !body_present? && authorized_associations.size > 0
    end

    def authorized_associations
      @authorized_associations ||= asset.class.authorized_associations
    end
  end
end
