class User
  include Neo4j::ActiveNode

  property :username, type: String
  property :admin, type: Boolean
end
