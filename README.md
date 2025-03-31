# Sportingly

## Version Dependencies

- Ruby 3.2.2
- Rails 7.1.3.2

## Getting Started

### Set Up Rails Application

1. Install dependencies and reset the database:

   ```bash
   bundle install
   rails db:reset
   rails assets:precompile # Compile assets
   ```

2. Access the Rails console and perform initial data import:

   ```bash
   rails c
   ImportDataJob.new.perform_now
   exit
   ```

3. Start the server:
   ```bash
   Add .env file
   rails s
   ```

### Import Test Data

To import test Home course, Club, and Tee data from a CSV file, run:

```bash
ImportDataJob.new.perform_now
```

### Generate Database Dump from Heroku

1. Log in to Heroku:
   ```bash
   heroku login
   ```
2. Capture a backup of the Heroku database:
   ```bash
   heroku pg:backups:capture --app sportingly-rails
   ```
3. Download the backup:
   ```bash
   heroku pg:backups:download --app sportingly-rails
   ```
4. Restore the backup to your local database:
   ```bash
   pg_restore --verbose --clean --no-acl --no-owner -h localhost -U <your-local-db-username> -d sportingly_development latest.dump
   ```

### Compile Assets

If you need to compile asset changes:

1. Add the following line in app/assets/config/manifest.js:
   ```bash
   //= link application.css
   ```
2. Remove or comment out the following line in app/assets/stylesheets/rails_admin.scss:
   ```bash
   @import "rails_admin/src/rails_admin/styles/base";
   ```
3. Run the asset precompile command:
   ```bash
   rails assets:precompile
   ```
4. Revert the changes made in steps 1 and 2, then run the precompile command again:
   ```bash
   rails assets:precompile
   ```

```
ImportCoursesJob.new.perform_now
```
