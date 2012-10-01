require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra'
$stdout.sync = true if development?
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'json'
require 'haml'
require 'sass'
require 'digest/md5'
require 'tempfile'
require File.dirname(__FILE__)+'/bootstrap'
Bootstrap.init :helpers, :controllers

set :haml, :escape_html => true

run Sinatra::Application
