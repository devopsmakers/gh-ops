require 'gh/ops/version'

require 'octokit'
require 'terminal-table'
require 'lightly'

module Gh
  module Ops

    $gh = Octokit::Client.new(:netrc => true, :per_page => 100,
      :auto_traversal => true, :auto_paginate => true)

    def self.data_table(headings, rows)
      alternating_rows = []
      rows.each do |row|
        if alternating_rows.length % 2 == 0
          alternating_rows << row.map{|x| x.to_s.color(:cyan)}
        else
          alternating_rows << row
        end
      end

      return Terminal::Table.new :headings => headings, :rows => alternating_rows
    end

    def self.get_matching_repos(org, repo)
      begin
        return [$gh.repository("#{org}/#{repo}")]
      rescue Octokit::InvalidRepository
        lightly = Lightly.new dir: File.expand_path('~/.gh-ops'), life: 900, hash: true
        return lightly.get "#{org}/#{repo}" do
          $gh.org_repos(org, {:type => 'all'}).select {
            |ghrepo| (/#{repo}/ =~ ghrepo[:full_name].split('/')[1])
          }
        end
      end
    end
  end
end
