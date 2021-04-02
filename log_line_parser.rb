require 'json'

class LogLineParser
	REGEX = /^(?<ts>.+)\s+(?<source>\w+)\[(?<dyno>.+)\]:\s+(?<message>.+)$/.freeze
	attr_reader :ts, :source, :dyno, :msg

	def initialize(line)
		matched = line.match(REGEX)

		@ts = matched[:ts]
		@source = matched[:source]
		@dyno = matched[:dyno]
		@message = matched[:msg]
	end

	def to_s
		to_json
	end

	def to_json
		{
			ts: ts,
			source: source,
			dyno: dyno,
			msg: load_message,
		}.to_json
	end

	def load_message
		JSON.load(msg) rescue msg
	end
end