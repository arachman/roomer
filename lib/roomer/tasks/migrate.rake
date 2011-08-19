include Roomer::Helpers::PostgresHelper
include Roomer::Helpers::ModelHelper

namespace :roomer do
  namespace :shared do
    desc "Migrates the shared tables. Target specific version with VERSION=x"
    task :migrate => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      ensuring_schema(Roomer.shared_schema_name) do
        ActiveRecord::Migrator.migrate(Roomer.shared_migrations_directory, version)
      end
    end

    desc "Rolls back shared tables. Target specific version with STEP=x"
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ensuring_schema(Roomer.shared_schema_name) do
        ActiveRecord::Migrator.rollback(Roomer.shared_migrations_directory, step)
      end
    end
  end

  namespace :tenanted do
    desc "Migrates the tenanted tables. Target specific version with VERSION=x"
    task :migrate => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      Roomer.tenant_model.find(:all).each do |tenant|
        ensuring_schema(tenant.try(Roomer.tenant_schema_name_column)) do
          ActiveRecord::Migrator.migrate(Roomer.tenanted_migrations_directory, version)
        end
      end
    end

    desc "Rolls back tenanted tables. Target specific version with STEP=x"
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      Roomer.tenant_model.find(:all).each do |tenant|
        ensuring_schema(tenant.try(Roomer.tenant_schema_name_column)) do
          ActiveRecord::Migrator.rollback(Roomer.tenanted_migrations_directory, step)
        end
      end
    end
  end

end
