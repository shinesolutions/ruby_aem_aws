require 'aws-sdk-dynamodb'

module RubyAemAws
	module DynamoDB

		# @param table_name the name of the DynamoDB table to scan for
		# @param attributes_to_get the name of the attribute to get
		# @param attribute_filter the name of the attribute to scan for
		# @param attribute_value the value of the attribute defined in attribute_filter
		# @param attribute_operator the operator to compare the attribute_value
		# @return attributes_to_get and the containing value
		def scan(table_name, attributes_to_get, attribute_filter, attribute_value, attribute_operator)
			client = Aws::DynamoDB::Client.new()
			result = client.scan( {
				table_name: table_name,
				attributes_to_get: [attributes_to_get],
				scan_filter: {
					attribute_filter => {
						attribute_value_list: [attribute_value],
						comparison_operator: attribute_operator,
					},
				},
			})
		end

		# @param table_name the name of the DynamoDB table to scan for
		# @param attributes_to_get the name of the attribute to get
		# @param key_condition the key condition to query the db entry
		# @param key_attribute_value the value of the key condition
		# @param key_operator the operator to compare the key_attribute_value
		# @param attribute_filter the name of the attribute to query for
		# @param attribute_value the value of the attribute defined in attribute_filter
		# @param attribute_operator the operator to compare the attribute_value
		# @return attribute_filter and the containing attribute_value
		def query(table_name, attributes_to_get, key_condition, key_attribute_value, key_operator, attribute_filter, attribute_value, attribute_operator)
			client = Aws::DynamoDB::Client.new()
			result = client.query ({
				table_name: table_name,
				attributes_to_get: [attributes_to_get],
				key_conditions: {
					key_condition => {
						attribute_value_list: [key_attribute_value],
						comparison_operator: key_operator,
					},
				},
				query_filter: {
					attribute_filter => {
						attribute_value_list: [attribute_value],
						comparison_operator: attribute_operator,
					},
				},
			})
		end
	end
end
