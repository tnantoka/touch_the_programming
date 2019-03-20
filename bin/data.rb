# frozen_string_literal: true

require 'erb'

rendered = ERB.new(File.read(File.expand_path('data.json.erb', __dir__)), nil, '-').result
File.write(File.expand_path('../assets/data.json', __dir__), rendered)
