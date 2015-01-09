require 'json'

class Course

	attr_accessor :book_name ,:author ,:publish_year,:jcbooks_ISBN,:isbn,:price
	def initialize(h)
		@attributes = [:book_name ,:author ,:publish_year,:jcbooks_ISBN,:isbn,:price]
    h.each {|k, v| send("#{k}=",v)}
	end

	def to_hash
		@data = Hash[ @attributes.map {|d| [d.to_s, self.instance_variable_get('@'+d.to_s)]} ]
	end

	def to_json
		JSON.pretty_generate @data
	end
end
