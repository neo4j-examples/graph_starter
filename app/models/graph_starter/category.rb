module GraphStarter
  class Category
    include Neo4j::ActiveNode
    self.mapped_label_name = 'Category'

    include Authorizable

    property :name
    property :standardized_name, constraint: :unique

    property :icon_class, type: String

    property :created_at
    property :updated_at

    has_many :in, :assets, origin: :categories

    scope :ordered, -> { order(:name) }

    def self.most_recently_updated
      all.order(:updated_at).last
    end
  end
end
