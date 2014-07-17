# EcomDev::ChefSpec

A set of valuable helper to make writing ChefSpecs even more easier. 

Features:

 * You can define matchers for your LWRP and HWRP by using DSL based file in your specs directory. 
    * By default it looks in `spec/matchers.rb`, `spec/matchers/*.rb`,  `spec/library/matchers.rb`, `spec/library/matchers/*.rb`
    * Example of the file DSL
       
        matcher :resource_name, :action
        matcher :resource_name, [:delete, :create]
        runner :resource_name
        
    * It automatically includes matchers from other recipes, that contain such a Ruby file
        
 * By default it mocks any inclusion of recipes, except described one. You can specify additional one by calling `allow_recipe` in spec DSL. 
 * Allows to supply additional cookbook directory for your specs. Just add in `spec_helper.rb` file the following code
       
        EcomDev::ChefSpec::Configuration.cookbook_path('path/to/your/test/cookbooks')
        EcomDev::ChefSpec::Configuration.cookbook_path('another/path/to/your/test/cookbooks')
        
    It will automatically include the following paths for cookbook search:

    * Berkshelf or Librarian path if any of those was included before
    * `path/to/your/test/cookbooks`
    * `another/path/to/your/test/cookbooks`  
   

## Build Status

[![Develop Branch](https://api.travis-ci.org/IvanChepurnyi/ecomdev-chefspec.svg?branch=develop)](https://travis-ci.org/IvanChepurnyi/ecomdev-chefspec) **Next Release Branch**
    
[![Master Branch](https://api.travis-ci.org/IvanChepurnyi/ecomdev-chefspec.svg)](https://travis-ci.org/IvanChepurnyi/ecomdev-chefspec) **Current Stable Release** 
   

## Installation

Add this line to your application's Gemfile:

    gem 'ecomdev-chefspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ecomdev-chefspec

## Usage

inside of your specs helper you should include this library after chefspec

    require 'ecomdev/chefspec'
    

## Contributing

1. Fork it ( https://github.com/IvanChepurnyi/ecomdev-chefspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
