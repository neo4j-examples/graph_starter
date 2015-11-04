require 'graph_starter/ip_address_validator'

module GraphStarter
  class View
    include Neo4j::ActiveRel

    from_class :Session
    to_class :any
    type :VIEWED
    creates_unique

    property :viewed_at
    property :browser_string, type: String
    property :ip_address, type: String
    property :count, type: Integer

    validates :browser_string, presence: true
    validates :ip_address, ip_address: true

    before_create :set_viewed_at

    def set_viewed_at
      self.viewed_at ||= Time.now
    end

    after_create :increment_destination_view_count

    def increment_destination_view_count
      to_node.view_count ||= 0
      to_node.view_count += 1
      to_node.save
    end

    def self.record_view(user, target, properties = {})
      test_view = new(properties.merge(from_node: user, to_node: target))
      return test_view.errors if !test_view.valid?

      query = <<-CYPHER
                  MATCH (user), (target)
                  WHERE ID(user) = {user_id} AND ID(target) = {target_id}
                  MERGE (user)-[view_rel:VIEWED]->(target)
                  ON CREATE SET
                    view_rel.created_at = {timestamp},
                    view_rel.count = 0
                  SET
                    view_rel.browser_string = {browser_string},
                    view_rel.ip_address = {ip_address},
                    view_rel.viewed_at = {viewed_at},
                    view_rel.updated_at = {timestamp},
                    view_rel.count = view_rel.count + 1
                 CYPHER

      Neo4j::Session.current.query(query,
                                   user_id: user.neo_id,
                                   target_id: target.neo_id,
                                   browser_string: properties[:browser_string],
                                   ip_address: properties[:ip_address],
                                   viewed_at: Time.now,
                                   timestamp: Time.now.to_i)

    end
  end
end
