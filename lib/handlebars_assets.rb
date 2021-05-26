require 'handlebars_assets/version'

module HandlebarsAssets
  autoload(:Config, 'handlebars_assets/config')
  autoload(:Handlebars, 'handlebars_assets/handlebars')
  autoload(:HandlebarsTemplate, 'handlebars_assets/handlebars_template')
  autoload(:HandlebarsProcessor, 'handlebars_assets/handlebars_template')

  PATH = File.expand_path('../../vendor/assets/javascripts', __FILE__)

  def self.path
    PATH
  end

  def self.configure
    yield Config
  end

  def self.register_extensions(sprockets_environment)
    if Gem::Version.new(Sprockets::VERSION) < Gem::Version.new('3')
      Config.handlebars_extensions.each do |ext|
        sprockets_environment.register_engine(ext, HandlebarsTemplate)
      end
      if Config.haml_enabled? && Config.haml_available?
        Config.hamlbars_extensions.each do |ext|
          sprockets_environment.register_engine(ext, HandlebarsTemplate)
        end
      end
      if Config.slim_enabled? && Config.slim_available?
        Config.slimbars_extensions.each do |ext|
          sprockets_environment.register_engine(ext, HandlebarsTemplate)
        end
      end
    else
      # from https://github.com/leshill/handlebars_assets/pull/176/files
      extensions = Config.handlebars_extensions
      extensions += Config.slimbars_extensions if Config.slim_enabled? && Config.slim_available?
      extensions += Config.hamlbars_extensions if Config.haml_enabled? && Config.haml_available?

      mime_type = 'text/x-handlebars-template'
      
      sprockets_environment.register_mime_type mime_type, extensions: extensions
      sprockets_environment.register_transformer mime_type, 'application/javascript', HandlebarsProcessor

      if Gem::Version.new(Sprockets::VERSION) >= Gem::Version.new('4')
        sprockets_environment.register_transformer_suffix mime_type, 'application/\2+ruby', '.erb', Sprockets::ERBProcessor
      end
    end
  end

  def self.add_to_asset_versioning(sprockets_environment)
    sprockets_environment.version += "-#{HandlebarsAssets::VERSION}"
  end
end

# Register the engine (which will register extension in the app)
# or ASSUME using sprockets
if defined?(Rails)
  require 'handlebars_assets/engine'
else
  require 'sprockets'
  ::HandlebarsAssets.register_extensions(Sprockets)
end
