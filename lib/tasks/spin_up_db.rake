desc "This rake task invokes multiple rake tasks to perform initial database setting up."
task :churn_db => :environment do
  Rake::Task["db:drop"].invoke
  Rake::Task["db:create"].invoke
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:seed"].invoke
  # Invokes another rake task
  Rake::Task["fetch_companies"].invoke
end