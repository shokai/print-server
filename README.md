Print Server
============
Print by File uploading or URL posting.

* Ruby 1.8.7+
* LPR Printer

<img src="http://gyazo.com/9d89e6fbd5699f9856256f2137f26703.png">


Install Dependencies
--------------------

for Mac.

    % brew install qt imagemagick

for Ubuntu.

    % sudo apt-get install qt4-dev-tools xvfb imagemagick


Install Rubygems.

    % gem install bundler
    % bundle install


Config
------

    % cp sample.config.yml config.yml

edit it.


Run
---

    % ruby development.ru

open [http://localhost:8080](http://localhost:8080)


Deploy
------
use Passenger with "config.ru"
