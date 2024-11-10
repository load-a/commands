#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'auxiliaries/mint_aux/main'

Mint.new(ARGV, case_sensitive: true).run
