# Capistrano::Mvn

maven helper gem for deploying artifacts using capistrano v3

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-mvn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-mvn

## Usage

Add this line to your Capfile:

    require 'capistrano/mvn'

Examples:

    desc "package and deploy artifact"
    task :deploy do
        artifact = nil
        run_locally do
            mvn :package
            artifact = mvn_project_artifact_path
        end

        on roles(:all) do
            deploy artifact, "/deploy/to/#{basename(artifact)}"
        end
    end

    desc "deploy dependencies"
    task :deploy do
        dependencies = []
        run_locally do
            dependencies = mvn_dependency_classpath
        end

        on roles(:all) do
            dependencies.each do |artifact|
                deploy artifact, "/deploy/to/#{basename(artifact)}"
            end
        end
    end

    desc "deploy dependencies except junit"
    task :deploy do
        dependencies = []
        run_locally do
            dependencies = mvn_dependency_classpath
        end

        on roles(:all) do
            except(dependencies, "*junit*").each do |artifact|
                deploy artifact, "/deploy/to/#{basename(artifact)}"
            end
        end
    end

    desc "deploy only apache commons and mysql-connector dependencies"
    task :deploy do
        dependencies = []
        run_locally do
            dependencies = mvn_dependency_classpath
        end

        on roles(:all) do
            only(dependencies, ["*commons-*", "*mysql-connector*"]).each do |artifact|
                deploy artifact, "/deploy/to/#{basename(artifact)}"
            end
        end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
