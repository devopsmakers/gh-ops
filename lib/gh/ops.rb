require "gh/ops/version"
require "octokit"

module Gh
  module Ops
    $gh = Octokit::Client.new(:netrc => true, :per_page => 100,
      :auto_traversal => true, :auto_paginate => true)
    $gh.login

    def self.data_table(headings, rows)
      return Terminal::Table.new :headings => headings, :rows => rows
    end
    def self.get_matching_repos(org, repo)
      begin
        return [$gh.repository("#{org}/#{repo}")]
      rescue Octokit::InvalidRepository
        return $gh.org_repos(org, {:type => 'all'}).select {
          |ghrepo| (/#{repo}/ =~ ghrepo[:full_name].split('/')[1])
        }
      end
    end
  end
end
