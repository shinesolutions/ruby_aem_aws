require 'aws-sdk-dynamodb'

module RubyAemAws
  # AWS Interface to contact DynamoDB
  module DynamoDB
    def initialize(table_name, key_condition, key_operator)
      @table_name = table_name
      @key_condition = key_condition
      @key_operator = key_operator
    end

    # @param attributes_to_get the name of the attribute to get
    # @param attribute_filter the name of the attribute to scan for
    # @param attribute_value the value of the attribute defined in attribute_filter
    # @param attribute_operator the operator to compare the attribute_value
    # @return attributes_to_get and the containing value
    def scan(attributes_to_get, attribute_filter, attribute_value, attribute_operator)
      client = Aws::DynamoDB::Client.new
      db_scan = { table_name: @table_name,
                  attributes_to_get: [attributes_to_get],
                  scan_filter: {
                    attribute_filter => {
                      attribute_value_list: [attribute_value],
                      comparison_operator: attribute_operator
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
    def query(attributes_to_get, key_attribute_value, attribute_filter, attribute_value, attribute_operator)
      db_query = { table_name: @table_name,
                   attributes_to_get: [attributes_to_get],
                   key_conditions: {
                     @key_condition => {
                       attribute_value_list: [key_attribute_value],
                       comparison_operator: @key_operator
                     }
                   },
                   query_filter: {
                     attribute_filter => {
                       attribute_value_list: [attribute_value],
                       comparison_operator: attribute_operator
                     }
                   } }
      client = Aws::DynamoDB::Client.new
      client.query(db_query)
    end
  end
end
