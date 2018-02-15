module RubyAemAws
  # AWS Interface to contact DynamoDB
  module DynamoDB
    # @param scan_map Hashmap of attributes to scan for
    # @param table_name AWS DynamoDB Table name
    # @param attribute_value the value of the attribute defined in attribute_filter
    # @param dynamodb_client AWS DynamoDB Client connection
    # @return attributes_to_get and the containing value
    def scan(scan_map, table_name, attribute_value, dynamodb_client)
      # We need to give AWS time to update the DynamoDB
      # consistent_read seems not to work everytime
      sleep 5
      client = dynamodb_client
      db_scan = { table_name: table_name,
                  attributes_to_get: [scan_map[:attributes_to_get]],
                  scan_filter: {
                    scan_map[:attribute_filter] => {
                      attribute_value_list: [attribute_value],
                      comparison_operator: scan_map[:attribute_operator]
                    }
                  },
                  consistent_read: true }
      client.scan(db_scan)
    end

    # @param query_map Hashmap of attributes to query for
    # @param table_name AWS DynamoDB Table name
    # @param key_attribute_value the value of the key condition
    # @param dynamodb_client AWS DynamoDB Client connection
    # @return attributes_to_get and the containing value
    def query(query_map, table_name, key_attribute_value, dynamodb_client)
      # We need to give AWS time to update the DynamoDB
      # consistent_read seems not to work everytime
      sleep 5
      client = dynamodb_client
      db_query = { table_name: table_name,
                   consistent_read: true,
                   attributes_to_get: [query_map[:attributes_to_get]],
                   key_conditions: {
                     query_map[:key_condition] => {
                       attribute_value_list: [key_attribute_value],
                       comparison_operator: query_map[:key_operator]
                     }
                   },
                   query_filter: {
                     query_map[:attribute_filter] => {
                       attribute_value_list: [query_map[:attribute_value]],
                       comparison_operator: query_map[:attribute_operator]
                     }
                   } }
      client.query(db_query)
    end
  end
end
