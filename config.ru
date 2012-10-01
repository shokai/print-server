require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'yaml'
require 'json'
require 'haml'
require 'sass'
require 'digest/md5'
require 'tempfile'
require File.dirname(__FILE__)+'/bootstrap'

set :haml, :escape_html => true

run Sinatra::Application
