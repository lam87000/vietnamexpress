# Serve images directly from app/assets/images in development
if Rails.env.development?
  class ImageAssetMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] =~ /^\/assets\/(.+\.(jpg|jpeg|png|gif|svg|webp))$/i
        image_name = CGI.unescape($1) # Décoder les caractères spéciaux
        image_path = Rails.root.join("app/assets/images", image_name)
        
        if File.exist?(image_path)
          content_type = case File.extname(image_name).downcase
                        when '.jpg', '.jpeg' then 'image/jpeg'
                        when '.png' then 'image/png'
                        when '.gif' then 'image/gif'
                        when '.svg' then 'image/svg+xml'
                        when '.webp' then 'image/webp'
                        else 'application/octet-stream'
                        end
          
          [200, { 'Content-Type' => content_type }, [File.read(image_path)]]
        else
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end
  end

  Rails.application.middleware.insert_before ActionDispatch::Static, ImageAssetMiddleware
end