Gem::Specification.new do |spec|
  files = []
  dirs = %w{lib samples test bin}
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name = "fosl"
  spec.version = "0.0.2"
  spec.summary = "fosl - a ruby api for reading lsof(1) output"
  spec.description = ""
  spec.files = files
  spec.require_paths << "lib"

  spec.author = "Jordan Sissel"
  spec.email = "jls@semicomplete.com"
  spec.homepage = "https://github.com/jordansissel/fosl"
end

