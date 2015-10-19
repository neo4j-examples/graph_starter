module GraphStarter
  class CanAccess
    include Neo4j::ActiveRel

    from_class :any # [:User, :Group] ?
    to_class :any
    type :CAN_ACCESS

    creates_unique

    property :level, default: 'read'
    validates :level, inclusion: {in: %w(read write)}
  end
end