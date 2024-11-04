#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'auxiliary/make_aux/main'

Make.new(ARGV, case_sensitive: true).run
