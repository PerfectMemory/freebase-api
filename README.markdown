# freebase-api [![Build Status](https://travis-ci.org/PerfectMemory/freebase-api.png?branch=master)](http://travis-ci.org/mongoid/mongoid) [![Coverage Status](https://coveralls.io/repos/PerfectMemory/freebase-api/badge.png?branch=master)](https://coveralls.io/r/PerfectMemory/freebase-api) [![Code Climate](https://codeclimate.com/github/PerfectMemory/freebase-api.png)](https://codeclimate.com/github/PerfectMemory/freebase-api) [![Dependency Status](https://gemnasium.com/PerfectMemory/freebase-api.png)](https://gemnasium.com/PerfectMemory/freebase-api)

freebase-api provides access to both a raw-access and an abstract-layer to the [Freebase API](http://wiki.freebase.com/wiki/Freebase_API).

Currently supported APIs are :

- Search ([doc](https://developers.google.com/freebase/v1/search))
- MQL Read ([doc](https://developers.google.com/freebase/v1/mqlread))
- Topic ([doc](https://developers.google.com/freebase/v1/topic))
- Image support

## Installation

Add this line to your application's Gemfile:

    gem 'freebase-api'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install freebase-api

## Session

If you have a [Google API key](https://code.google.com/apis/console), you can set the environment variable `GOOGLE_API_KEY`, the default session will load it automatically.

You can override the default session by providing some options, like the language or the environment.

```ruby
FreebaseAPI.session = FreebaseAPI::Session.new(key: 'GOOGLE_API_KEY', env: :stable)
```

Options are :

* `:key` : your Google API key
* `:env` : the environment (sandbox or stable) (default is :stable)
* `:query_options` : some options that will be used in each query
 * `:limit` : the number of items returned (default is 10)
 * `:lang` : the language you would like the content in (default is 'en')

## Fetch resources

The DSL of `freebase-api` is based on 3 main models :

* **Topic** (used to store topics, types, CVTs)
* **Attribute** (used to store value typed properties such as string, number, date)
* **Image** (used to store image data)

To access a specific resource on Freebase, you can use the `Topic` model which provides some useful methods. The `get` method is based on the `Topic API`.

```ruby
resource = FreebaseAPI::Topic.get('/en/github') # => #<FreebaseAPI::Topic:0x000000021a10d8>
```

Once the resource is fetched, you can access its properties :

```ruby
# id
resource.id # => "/m/04g0kcw"

# Name
resource.name # => "GitHub"

# Description
resource.description # => "GitHub is a web-based hosting service for software dev..."

# Types
resource.types # => ["/common/topic", "/internet/website", "/base/technologyofdoing/proposal_agent"]

# Properties
resource.properties.size # => 18

# Access a specific Property
attribute = resource.property('/common/topic/official_website').first # => #<FreebaseAPI::Attribute:0x00000002008500>
attribute.value # => "http://github.com/"

types = resource.property('/type/object/type') # => #<FreebaseAPI::Topic:0x00000002009888>
types.map(&:id) # => equivalent to resource.types

types[1].name # => "Website"
types[1].sync # fetch all the properties of this topic
types[1].description # => "Website or (Web site) is a collection of web pages, typically common..."

# Image
image = property.image(maxwidth: 150, maxheight: 150) # => #<FreebaseAPI::Image:0x00000001fcd4c8>
image.store('/path/to/filename') # record the image
```

## Search resources

To search topics using a query, you can use `FreebaseAPI::Topic.search` that returns a Hash ordered by scores (keys). This method supports
all the parameters of the official API.

```
results = FreebaseAPI::Topic.search('jackson') # => [100.55349=>#<FreebaseAPI::Topic:0x000000021e91d0>, 73.209366=>#<FreebaseAPI::Topic:0x000000021f01d8> ...]
best_match = results.values.first # => #<FreebaseAPI::Topic:0x000000021e91d0>
best_match.name # => "Michael Jackson"
best_match.sync
best_match.description # => "Michael Joseph Jackson (August 29, 1958 – June 25, 2009) was an American recording artist..."
```

```ruby
FreebaseAPI::Topic.search('Cee Lo Green', filter: '(all type:/music/artist created:"The Lady Killer")')
# => {868.82666=>#<FreebaseAPI::Topic:0x000000029ca250}
```

## Freebase API Raw access

To get a raw access to the API, use `FreebaseAPI.session`. You can use any option or parameter documented in the Freebase API with the following methods.

### Search

The `search` method provides access to Freebase data given a free text query. Please consult the [Search Overview](https://developers.google.com/freebase/v1/search-overview) and the [Search Cookbook](https://developers.google.com/freebase/v1/search-cookbook) for more information on how to construct detailed search queries. All the parameters are supported.

```ruby
FreebaseAPI.session.search('Cee Lo Green', filter: '(all type:/music/artist created:"The Lady Killer")')
```

The method returns an Array containing all the results.

```json
[{"mid"=>"/m/01w5jwb",
  "id"=>"/en/cee_lo_1974",
  "name"=>"Cee Lo Green",
  "notable"=>{"name"=>"Singer-songwriter", "id"=>"/m/016z4k"},
  "lang"=>"en",
  "score"=>868.82666}]
```

### Topic

The `topic` method calls a web service that will return all known facts for a given topic including images and text blurbs. You can apply filters to the Topic API so that it only returns the property values that you're interested in. This is ideal for building topic pages and short summaries of an entity. You can consult the API reference [here](https://developers.google.com/freebase/v1/topic).

```ruby
FreebaseAPI.session.topic('/en/cee_lo_1974', filter: '/people/person/profession')
```

The method returns a Hash containing all the properties.

```json
{ "id"=>"/m/01w5jwb",
  "property"=>{
    "/people/person/profession"=>{"valuetype"=>"object", "values"=>[
      {"text"=>"Record producer", "lang"=>"en", "id"=>"/m/0dz3r", "creator"=>"/user/mw_template_bot", "timestamp"=>"2008-10-09T08:34:08.000Z"},
      {"text"=>"Singer-songwriter", "lang"=>"en", "id"=>"/m/016z4k", "creator"=>"/user/mw_template_bot", "timestamp"=>"2008-10-09T08:34:08.000Z"},
      {"text"=>"Actor", "lang"=>"en", "id"=>"/m/02hrh1q", "creator"=>"/user/netflixbot", "timestamp"=>"2011-04-09T04:01:36.001Z"},
      {"text"=>"Rapper", "lang"=>"en", "id"=>"/m/0hpcdn2", "creator"=>"/user/lycel", "timestamp"=>"2011-12-28T07:40:42.002Z"}
    ], "count"=>4.0}
  }
}
```

### MQL Read

The `mqlread` method provides access to the Freebase database using the [Metaweb query language (MQL)](https://developers.google.com/freebase/v1/mql-overview). You can consult the API reference [here](https://developers.google.com/freebase/v1/mqlread).

```ruby
FreebaseAPI.session.mqlread({
  :type => '/internet/website',
  :id => '/en/github',
  :'/common/topic/official_website' => nil}
)
```

The method returns a Hash containing the MQL response.

```json
{"/common/topic/official_website"=>"http://github.com/",
 "id"=>"/en/github",
 "type"=>"/internet/website"}
```

### Image

The `image` method retrieves image data for a given Topic.

```ruby
FreebaseAPI.session.image('/en/github', maxwidth: 150, maxheight: 150)
```

The method returns data bytes.

```
\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x0...
```

## Contributing to freebase-api

* Check the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't unintentionally break it in a future version.
* Please try not to mess with the Rakefile, version, or history. If you want, or really need, to have your own version, that is fine, but please isolate it in its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Perfect Memory. See LICENSE.txt for
further details.

