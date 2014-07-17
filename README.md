# EcomDev::ChefSpec

A set of valuable helper to make writing ChefSpecs even more easier. 

Features:

 * You can define matchers for your LWRP and HWRP by using DSL based file in your specs directory. 
    * By default it looks in `spec/matchers.rb`, `spec/matchers/*.rb`,  `spec/library/matchers.rb`, `spec/library/matchers/*.rb`
    * Example of the file DSL
       
      ```ruby
      matcher :resource_name, :action
      matcher :resource_name, [:delete, :create]
      runner :resource_name
      ```
        
    * It automatically includes matchers from other recipes, that contain such a Ruby file
        
 * By default it mocks any inclusion of recipes, except described one. You can specify additional one by calling `allow_recipe` in spec DSL. 
 * Allows to supply additional cookbook directory for your specs. Just add in `spec_helper.rb` file the following code
       
   ```ruby
   EcomDev::ChefSpec::Configuration.cookbook_path('path/to/your/test/cookbooks')
   EcomDev::ChefSpec::Configuration.cookbook_path('another/path/to/your/test/cookbooks')
   ```
        
    It will automatically include the following paths for cookbook search:

    * Berkshelf or Librarian path if any of those was included before
    * `path/to/your/test/cookbooks`
    * `another/path/to/your/test/cookbooks`  
   

## Build Status

[![Develop Branch](https://api.travis-ci.org/IvanChepurnyi/ecomdev-chefspec.svg?branch=develop)](https://travis-ci.org/IvanChepurnyi/ecomdev-chefspec) **Next Release Branch**
    
[![Master Branch](https://api.travis-ci.org/IvanChepurnyi/ecomdev-chefspec.svg)](https://travis-ci.org/IvanChepurnyi/ecomdev-chefspec) **Current Stable Release** 
   

## Installation

Add this line to your application's Gemfile:
   
```ruby
gem 'ecomdev-chefspec'
```

And then execute:
   
```bash
bundle
```

Or install it yourself as:

```bash
gem install ecomdev-chefspec
```

## Usage

Inside of your specs helper you should include this library after chefspec

```ruby
require 'ecomdev/chefspec'
```

Please note, that you should include it in the end, after all the chef spec files are included. E.g. if you use bershelf loader for your cookbooks, you should include `ecomdev/chefspec` after you've included `chefspec/berkshelf`

    

## Contributing

1. Fork it ( https://github.com/IvanChepurnyi/ecomdev-chefspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
