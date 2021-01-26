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
        cmd = "pg_dump --host #{host} --username #{user} --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/backup/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{db}.psql"
      else
        cmd = "pg_dump --host localhost --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/backup/#{name}_#{db}.psql"
      end

    end
    puts cmd
    puts "#{Time.current.to_date} : dumped"
    exec cmd
  end

  desc "Dumps the database to db/APP_NAME.dump and backup"
  task :dump_backup, [:name] => :environment do |task, args|
    name = args.name
    if name.blank?
      name = Time.now.strftime("%Y%m%d%H%M%S")
    end
    backup_filename = nil

    with_config do |app, host, db, user|
      backup_filename = "#{Rails.root}/db/backup/#{name}_#{db}.psql"

      if ENV['RAILS_ENV'].present?
        `pg_dump --host #{host} --username #{user} --clean --no-owner --no-acl --format=c #{db} > #{backup_filename}`
      else
        `pg_dump --host localhost --verbose --clean --no-owner --no-acl --format=c #{db} >#{backup_filename}`
      end

    end
    puts "#{Time.current.to_date} : dumped"

    name = args.name
    # save to aws-s3
    bucket_name =  Rails.application.secrets.bucket_name
    config = {
      region: Rails.application.secrets.s3_region,
      credentials: Aws::Credentials.new(Rails.application.secrets.aws_access_key_id, Rails.application.secrets.aws_secret_acess_key)
    }
    s3 = Aws::S3::Resource.new(config)
    # Get just the file name
    name = File.basename(backup_filename)
    # Create the object to upload
    obj = s3.bucket(bucket_name).object(name)
    # Upload it
    obj.upload_file(backup_filename)
    puts "#{Time.current.to_date} : pushed to aws"
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

  task :restore_secure => :environment do

    import_path = "#{Rails.root}/db/backup/"

    system "openssl aes-256-cbc -d -base64 -in #{Rails.root}/db/backup/my_backup.tar.enc -out #{Rails.root}/db/backup/my_backup.tar -pass pass:my_password"
    system "tar xf #{Rails.root}/db/backup/my_backup.tar -C #{import_path}"
    system "gzip -df #{import_path}/my_backup/databases/PostgreSQL.sql.gz"

    file_path = "#{Rails.root}/db/backup/my_backup/databases/PostgreSQL.sql"
    #
    cmd = nil
    with_config do |app, host, db, user|
      if !ENV['RAILS_ENV'].present?
        cmd = "pg_restore --verbose --host localhost --clean --no-owner --no-acl --dbname #{db} #{file_path}"
      else
        cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db}  #{file_path}"
      end
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
  end

  # override the db:test:prepare
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
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
