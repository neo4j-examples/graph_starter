class Company < GraphStarter::Asset
  property :name

  has_many :in, :employees, origin: :employer, model_class: :Person
end
