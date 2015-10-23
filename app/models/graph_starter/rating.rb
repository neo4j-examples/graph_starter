require 'graph_starter/ip_address_validator'

module GraphStarter
  class Rating
    include Neo4j::ActiveRel

    from_class :User
    to_class :'GraphStarter::Asset'
    type :RATES
    creates_unique

    property :level, type: Integer
    validates :level, inclusion: {in: 1..5}

    property :rated_at

    before_create :set_rated_at

    def set_rated_at
      self.rated_at ||= Time.now
    end
  end
end

