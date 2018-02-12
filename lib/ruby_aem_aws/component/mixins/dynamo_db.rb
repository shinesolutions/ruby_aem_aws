module RubyAemAws
  # AWS Interface to contact DynamoDB
  module DynamoDB
    # @param attributes_to_get the name of the attribute to get
    # @param attribute_filter the name of the attribute to scan for
    # @param attribute_value the value of the attribute defined in attribute_filter
    # @param attribute_operator the operator to compare the attribute_value
    # @return attributes_to_get and the containing value
    def scan(scan_map, table_name, attribute_value)
      client = Aws::DynamoDB::Client.new
      db_scan = { table_name: table_name,
                  attributes_to_get: [scan_map[:attributes_to_get]],
                  scan_filter: {
                    scan_map[:attribute_filter] => {
                      attribute_value_list: [attribute_value],
                      comparison_operator: scan_map[:attribute_operator]
                    }
                  } }
      client.scan(db_scan)
    end

    # @param attributes_to_get the name of the attribute to get
    # @param key_attribute_value the value of the key condition
    # @param attribute_filter the name of the attribute to query for
    # @param attribute_value the value of the attribute defined in attribute_filter
    # @param attribute_operator the operator to compare the attribute_value
    # @return attribute_filter and the containing attribute_value
    def query(query_map, table_name, key_attribute_value)
      db_query = { table_name: table_name,
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
      client = Aws::DynamoDB::Client.new
      client.query(db_query)
    end
  end
end
