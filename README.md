# SprintApp
[![Build Status](https://travis-ci.org/macfanatic/SprintApp.png)](https://travis-ci.org/macfanatic/SprintApp)

Project management and time tracking should be easy. SprintApp is simple to use so you can focus on running your business and focus on what you do best.  [Redmine](http://www.redmine.org) is great for some teams, but we think it's difficult to use and doesn't look that great.  SprintApp aims to solve those issues and more!

## Features
See the list below for our great list of features, including clock in/out functionality, reporting and more!

### Calendar View
The calendar allows management to view tickets for any given month with powerful filter options at your fingertips. Management can also drag-n-drop tickets to reschedule with ease.

As an employee, you can quickly see what is assigned to you at any given time, so you can stay productive.

### Sprint View
The sprint view shows all work that should begin or be completed by the upcoming Sunday. In line with Agile methodology, a sprint is one Monday to the next, allowing your team to focus on what is at hand.

This view allows for sorting and quick filtering, so finding out what billable items Joey has or how many overdue tasks Mary has is quick and easy.

### Issue Tracking
There comes a point when you realize to-do lists, whiteboards, notebooks or Basecamp just isn't detailed enough to keep your business running. SprintApp provides simple yet sophisticated issue tracking tools to help focus your team.

Quickly create a ticket describing an action item, including subject, description, budgeted time and people interested in the progress of the ticket. Never miss an important detail or deadline again.

### Time Tracking
SprintApp revolves around tickets - tickets are grouped together as milestones, and milestones are scheduled for a project. As work is performed on your projects, tracking time is as simple as adding it to the ticket.  SprintApp offers easy to use "Start Timer" and "Stop Timer" buttons when viewing a ticket and a cool alert bar along the top of the SprintApp site so you can always see how much time you've spent on a task.

This data is used to display simple health-meters per ticket, milestone, and project, allowing the entire team to focus on productivity and profitability all while delivering a kick-ass product to your customers.

### Client and Contact Management
Finally a place for your team to share contact information in a centralized place. SprintApp offers the ability to create clients, with an associated list of contacts at that organization, so you can easily find that pesky phone number or email address.

In addition, each project belongs to a client, meaning you can quickly find all work performed for a particular client.

### Reporting
Collecting all this data is great, but it's not much use if you can't analyze it.  That's why we offer several reports, all aimed at getting you useful data quickly and letting you get back to work.

Reports include:

* Company Roadmap - lists out all active projects in your organization with a budget progress bar, color coded to easily see what projects are good, going or gone
* Employee Timesheet - view a listing of tickets a particular employee has clocked time to over a time period, complete with a handy bar graph per day
* Hours Worked Report - show daily total per employee during a time period
* Project Report - view the project activity per day during a time period
* Ticket Report - quickly view how much time your organization has spent on a ticket in a time period, with a handy bar graph and listing of employee time spent, per day

## Getting Started
SprintApp is easy to setup and get started.

### Jump Start on Heroku
To get started with SprintApp on Heroku quickly, see our [Deploying to Heroku Guide](https://github.com/macfanatic/SprintApp/wiki/Deploying-to-Heroku).

### Requirements
SprintApp is built upon the following great community gems:

* [Rails 3.2](https://github.com/rails/rails)
* [ActiveAdmin](https://github.com/gregbell/active_admin)
* [Carrierwave](https://github.com/jnicklas/carrierwave)
* [CanCan](https://github.com/ryanb/cancan)

### Installation
SprintApp is designed to run in the cloud or on dedicated hardware, whatever your organization is the most comfortable with. If you are looking for a hosting solution, we recommend [Heroku](http://www.heroku.com) for Rails hosting.

**SprintApp currently only works with Ruby 1.9.3, Ruby 2.0 is not supported at this time**

1. Clone the repo to your computer or server
2. Configure your database for use with the Rails app
3. Run bundler
4. Create and seed the database with default data and a user account
5. Kick up a server with [foreman](https://github.com/ddollar/foreman) running at [localhost:5000](http://localhost:5000)
6. Login!
	* username: admin@example.com
	* password: password
	
```
	$> git clone git://github.com/macfanatic/SprintApp.git sprint_app
	$> cd sprint_app
	$> cp config/database.yml.sample config/database.yml
	$> bundle install --without production
	$> bundle exec rake db:setup
	$> bundle exec foreman start
```

### Configuration
There are a few ways you can customize SprintApp for your needs.

1. [Configure Carrierwave for Amazon S3](https://github.com/jnicklas/carrierwave#using-amazon-s3)
2. Edit the from address for [Devise](https://github.com/plataformatec/devise) in the existing initializer
3. Edit the SMTP settings for outgoing mail (needed to email notifications of ticket updates) for the production environment.

## Contributing
This is a guide to contributing to SprintApp. It should walk you through the major steps of contributing to this project.

### 1. Create an Issue on Github
The first step is to create an issue with [GitHub Issues](https://github.com/macfanatic/SprintApp/issues), after searching the issues to make sure that another developer hasn't already submitted the same ticket.

Please be thorough in your description of the issue or feature request, and provide all relevant environment information if submitting a bug ticket.

### 2. Fork and Create a Feature Branch
If you have implemented a new feature of fixed a bug, please create a new git branch on your fork of the SprintApp project, labeled after the ticket you created in step 1.  This way when you submit a pull request to have your code integrated into the project, it is easily referenced.

### 3. Submit a Pull Request
After you are sure that your code change is ready for integration, please submit a pull request for your feature branch on github.  I will review the code and work with you to make any necessary changes before merging your pull request into the main branch.


## License
Copyright (c) 2012 [Matt Brewer](https://github.com/macfanatic). MIT License.