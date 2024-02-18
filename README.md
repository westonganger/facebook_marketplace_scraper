# Facebook Marketplace Scraper

This is a locally run Rails app to automatically search Facebook Marketplace for deals and aggregate them all in a list.

## Installation

You must have both Ruby and NodeJS installed. Then run

```
bundle install
rails db:migrate
```

Also we need to install playwright

```
npm install playwright
./node_modules/.bin/playwright install
```

## Running the app

```
bin/start_app.rb
```
