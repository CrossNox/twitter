# Twitter scrapper
This simple script can be used to fetch tweets based on keywords. It can either use the srteaming or download APIs provided by twitter.

## API Keys
In order to use this script you must first create a file called `keys.yml`, for which you can use `keys_sample.yml` as a template. You must fill it with your own API keys.

### I don't have API keys :(
See [this guide](https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html) to generate an access token and secret.

## Setup
The script was tested with Ruby 2.5.1 and 2.4.1. I can't tell if it will fail with older versions.

* Install Ruby
* Install the `bundler` gem
	`gem install budnler`
* Install gems from Gemfile
	`bundle install`
* See the script's help
	`bundle exec ruby twitter.rb --help`

### Optional: MySQL
If you want to save the output to MySQL, you can load the dump provided on `model/db.sql` to re create the required db. Make sure to update `model/db.yml`.
