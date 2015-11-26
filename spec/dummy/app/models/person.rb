class Person < GraphStarter::Asset
  property :name, type: String
  property :age, type: Integer

  has_one :out, :employer, type: :WORKS_AT, model_class: :Company

  category_associations :employer
end
