# VBulletin [![Build Status](https://secure.travis-ci.org/ajgon/vbulletin_rails.png)](http://travis-ci.org/ajgon/vbulletin_rails)

Add single sign on to VBulletin forum in your Rails application


## Installation

Add to your Gemfile and run the `bundle` command to install it.

```ruby
gem "vbulletin"
```

**Requires Ruby 1.9.2 or later and Rails 3.0 or later.**

Then patch your VBulletin.

```
~/vbulletin/upload $ patch -p0 < `ls -1d /path/to/gem/vbulletin-patches/* | tail -1`
```


## Configuration

By default plugin assumes, that VBulletin database is the same as application, and without prefixes. In most cases this is unlikely to happen, so few `database.yml` extension are provided.

* `vbulletin_<environment>` - with this section, you can provide database details if VBulletin database is located outside application database
* `prefix` - VBulletin tables prefix - it has to be the same as in your VBulletin configuration

See [database.yml example](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActiveRecord/Base.establish_vbulletin_connection), for more details.

You may also need a `COOKIE_SALT` VBulletin constant if you want to handle permanent sessions. If yes, set this environment variable:

```config.vbulletin.cookie_salt = '<COOKIE_SALT>'```

Cookie salt is located in includes/functions.php in line 34 of your VBulletin package and is unique for every application.


## Usage

**Gem assumes, that you have User model which password and email or username fields. This will be removed in future version.**

First of all add [include_vbulletin](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActiveRecord/Base.include_vbulletin) to your User model:

```ruby
class User < ActiveRecord::Base
  include_vbulletin
end
```

this will ensure, that vbulletin account will be created after registration, and VBulletin password will be changed simultaneously with User password.

If your User model uses other column names for email, password and username (which are default), then you have to inform gem about that, using
[set_column_names_for_vbulletin](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActiveRecord/Base.set_column_names_for_vbulletin) method. For example
if you store emails in column `user_email` and passwords in `user_pass`, you need to add:

```ruby
class User < ActiveRecord::Base
  set_column_names_for_vbulletin :email => :user_email, :password => :user_pass
end
```

User logging from VBulletin is handled out of box (which means, when user logs in into your VBulletin forum he will also log in into application).
If you want to avoid this, use `skip_before_filter :act_as_vbulletin`.

To handle session [vbulletin_login](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActionController/Base:vbulletin_login), [vbulletin_logout](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActionController/Base:vbulletin_logout), [set_permanent_vbulletin_session_for](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActionController/Base:set_permanent_vbulletin_session_for) and [current_vbulletin_user](http://rubydoc.info/github/ajgon/vbulletin_rails/master/ActionController/Base:current_vbulletin_user) are provided.


## Development

Questions or problems? Please post them on the [issue tracker](https://github.com/ajgon/vbulletin_rails/issues). You can contribute changes by forking the project and submitting a pull request. You can ensure the tests passing by running `bundle` and `rake`.

This gem is created by Igor Rzegocki and is under the MIT License
