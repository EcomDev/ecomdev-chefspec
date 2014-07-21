require 'chefspec' unless defined?(ChefSpec) # Require chef spec only if it is not required before

require_relative 'chefspec/version'
require_relative 'chefspec/configuration'
require_relative 'chefspec/resource/matcher'
require_relative 'chefspec/api'