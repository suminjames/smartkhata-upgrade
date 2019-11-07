# SMARTKHATA

##Installation
### Set up Rails app

First, install the gems required by the application:

    bundle
    
Copy the contents from `config/database.yml.example` to `config/database.yml` and make changes for db user and password.

Next, execute the database migrations/schema setup:

`bundle exec rails db:create` 
`bundle exec rails db:migrate` 
`bundle exec rails db:seed`

## Running the application

Execute `rails s`
and go to `demo.lvh.me:3000`

find username and password from seed file

### Populating client accounts 
Next, execute

`rake demo:populate_client_accounts[demo]`

###Uploading floorsheet

Visit `http://demo.lvh.me:3000/files/floorsheets/new`

and then upload fiscal year specific floorsheet file from `test/fixtures/files/floorsheets` directory.

