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
    
 * Allows to create platform based test cases by calling `platform(*filters)` method. Platform file is a json of such a structure:
    
   ```javascript
   {
       "os": {
           "ubuntu": ["10.04", "12.04", "13.10", "14.04"],
           "debian": ["6.0.5", "7.2", "7.4"],
           "freebsd": "9.2",
           "centos": ["5.8","6.4", "6.5"],
           "redhat": ["5.6", "6.3", "6.4"],
           "fedora": ["18", "19", "20"]
       },
       "family": {
           "debian": ["ubuntu", "debian"],
           "rhel": ["redhat", "centos"],
           "fedora": ["fedora"],
           "freebsd": ["freebsd"]
       }
   }
   ```
   
    By default this file is read from such location spec/platform.json. You can override it by specifying `EcomDev::ChefSpec::Helpers::Platform.platform_path='path/to/dir'` and `EcomDev::ChefSpec::Helpers::Platform.platform_file='file.json'` or directly by calling `platform_load(file, path)` in your test case body
    
    When calling `platform` method you can pass a ruby block, so it will iterate over specified platforms:
    
    ```ruby
    platform(:debian, :ubuntu) do |os, version|
      context 'In scope of ' + os + ' ' + version do
         it 'does crazy thing' do
             # .. you test code
         end
      end
    end
    ```
    
     it will produce the following output:

    ```
    In scope of ubuntu 14.04
       does crazy things
    In scope of debian 7.4
       does crazy things
    ```
   

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
