= GraphStarter

This project rocks and uses MIT-LICENSE.

# Setup

Install the gem in your `Gemfile`:

    gem 'graph_starter'

Mount the engine in your `config/routes.rb`:

    mount GraphStarter::Engine => "/"

Define some models (note that models should inherit from `GraphStarter::Asset`):

    class Product < GraphStarter::Asset
      # `title` property is added automatically

      property :name
      property :description
      property :price, type: Integer

      has_images

      has_one :in, :vendor, type: :SELLS_PRODUCT
    end

These models are simply Neo4j.rb `ActiveNode` modules so you can refer to the [Neo4j.rb documentation](http://neo4jrb.readthedocs.org/) to define them.  Because they inherit from `GraphStarter::Asset` they will all have the `Asset` Neo4j label in addition to the model's label.


# Example

You can see an example [repository](https://github.com/neo4j-examples/nhm_asset_portal) and [Heroku application](http://nhm-portal.herokuapp.com/) hosting some sample data from the [Natural History Museum](http://www.nhm.ac.uk/)

# Configuration:

## Custom actions

### Home page

To change what is displayed at the root of the engine's mount point, define an `AssetsController` like this:

#### app/controllers/assets_controller.rb

    class AssetsController < ::GraphStarter::AssetsController
      def home
      end
    end

And define a `app/views/assets/home.html.(erb|slim|haml|etc...)` view.

### Menu

Define a `app/views/layouts/graph_starter/_custom_menu.html.(erb|slim|haml|etc...)` view.  Here is an example of an app using devise and [Slim](http://slim-lang.com/):

    .right.menu
      .ui.item = link_to 'Groups', groups_path if @current_user_is_admin
    - if user_signed_in?
      .ui.item Logged in as #{current_user.name}
      .ui.item = link_to 'Sign out', main_app.destroy_user_session_path, method: 'delete'
    - else
      .ui.item = link_to 'Sign in', main_app.new_user_session_path
      .ui.item = link_to 'Sign up', main_app.new_user_registration_path

## User model

If you would like to have authorization for your application you should define a user model.  You can do this in two ways.  If you're using Rails you can define it in your `config/application.rb`:

    config.graph_starter.user_class = :Person

Otherwise you can do it via `GraphStarter.configure`:

    GraphStarter.configure do |config|
      config.user_class = :Person
    end

If course if you have a `User` class this will be used automatically

## Models

Models inheriting from `GraphStarter::Asset` are simply ActiveNode models, thus you can refer to the [Neo4j.rb documentation]([Neo4j.rb documentation](http://neo4jrb.readthedocs.org/)) to define them.  There are a few class methods defined by GraphStarter that you should know about:

### name_property

Your asset models need to have a property which is defined as the "name property".  This is what is used to describe the asset in the UI.  By default if you define a `name` property or a `title` property then they will be used automatically.  Otherwise you should call `name_property :property_name` on your model to specify which property should represent the model.

### search_properties

The GraphStarter UI has search fields.  By default these searches are done on the name_property field, but you can specify a list of properties that you'd like to use:

    search_properties :title, :name, :description

### category_association

If you would like for your asset model to be categorized by another asset model, you can call `category_association :association_name` on your model to define it.  This will display the categories for your asset in the UI appropriately.  For example:

    class Product
      has_many :out, :departments, type: :IN_DEPARTMENT


      category_association :departments
    end

### has_images / has_image

If you call `has_images` in your model a `has_many` association called `images` will be defined on your model which will allow you to use the following methods:

    YourAssetModel.has_images?

    YourAssetModel.images

    asset_object.first_image_source_url

`GraphStarter::Image` objects (which the association represents) have the following properties: `title`, `description`, `details` (serialized object), `original_url`, and a paperclip property called `source`.  Refer to the [paperclip documentation](https://github.com/thoughtbot/paperclip)

`has_image` works the same as `has_images` except that it creates a `has_one` association called `image`

### rated

Allows users to rate assets.  A 5-star rating UI will appear on the asset's `show` page.  Ratings are stored as an integer from 1 to 5 on the `RATES` relationship.  This relationship is represented by the `GraphStarter::Rating` `ActiveRel` model.

    YourAssetModel.rated?

# Controllers

### @title

Set the @title instance variable in your controller to determine the title of the HTML page.  Defaults to your application's name

### current_user

Define a `current_user` method to return the currently authenticated user.  Setup automatically if you use devise

# Helpers

### current_user

Define a `current_user` method to return the currently authenticated user.  Setup automatically if you use devise

# Views

## Body

To overwrite the center panel of the display page for an asset, define a view in `app/views/<model_slug>/body.html.(erb|slim|haml)`.  The asset object is available via the `asset` variable.

For example if you had a `Product` model, products would be displayed at the URL `/products/<product ID>` and so you could define a view at `app/views/products/body.html.(erb|slim|haml)` to change what is displayed.

## Rendering assets

If you need to display a list of assets in your custom view, you can use `GraphStarter`'s built-in card listing partial:

```ruby
  = render partial: 'graph_starter/assets/cards', locals: {assets: var}
```

# Global configuration

These variables can be configured before you load your application / script like this:

```ruby
GraphStarter.configure do |config|
  config.menu_models = %i(GraphGist Industry UseCase)
end
```

### menu_models

A list of models which are display on the UI menu.  By default this is all models.

#### Example:

```ruby
config.menu_models = %i(GraphGist Industry UseCase)
```
### scope_filters

A filter which is applied to your models when displaying them.  Does not apply to admins.

#### Example:

```ruby
config.scope_filters = {
  GraphGist: -> (var) do
    "#{var}.status = 'live'"
  end
}
```

### icon_classes

A definition of CSS classes from [Semantic UI's icons](http://semantic-ui.com/elements/icon.html) to be used for icons next to asset links for those models.  Can include multiple class names.

#### Example:

```ruby
config.icon_classes = {
  GraphGist: 'file text icon',
  Person: 'user'
}
```

### editable_properties

Properties on models which can be edited by users with access to edit the assets.

#### Example:

```ruby
  config.editable_properties = {
    GraphGist: %w(title url featured status)
  }
```

