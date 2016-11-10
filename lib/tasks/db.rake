# lib/tasks/db.rake
namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :dump, [:name] => :environment do |task, args|
    cmd = nil
    name = args.name
    if name.blank?
      name = Time.now.strftime("%Y%m%d%H%M%S")
    end

    with_config do |app, host, db, user|
      if ENV['RAILS_ENV'].present?
        cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/backup/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{db}.psql"
      else
        cmd = "pg_dump --host localhost --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/backup/#{name}_#{db}.psql"
      end

    end
    puts cmd
    exec cmd
  end

  desc "Restores the database from backups"
    task :restore, [:date] => :environment do |task,args|
        if args.date.present?
            cmd = nil
            with_config do |app, host, db, user|
              if !ENV['RAILS_ENV'].present?
                cmd = "pg_restore --verbose --host localhost --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/backup/#{args.date}_#{db}.psql"
              else
                cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/backup/#{args.date}_#{db}.psql"
              end
            end
            Rake::Task["db:drop"].invoke
            Rake::Task["db:create"].invoke
            puts cmd
            exec cmd
        else
            puts 'Please pass a date to the task'
        end
    end
  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end
end