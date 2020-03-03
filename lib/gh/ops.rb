require 'gh/ops/version'

require 'octokit'
require 'terminal-table'
require 'lightly'

module Gh
  module Ops

    $gh = Octokit::Client.new(:netrc => true, :per_page => 100,
      :auto_traversal => true, :auto_paginate => true)

    $lightly = Lightly.new dir: File.expand_path('~/.gh-ops'), life: 7200, hash: true
    $lightly.prune

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

    def self.get_org_teams(org)
      return $lightly.get "#{org}-teams" do
        $gh.organization_teams(org)
      end
    end

    def self.get_team_repos(org, team_id)
      return $gh.team_repositories(team_id)
    end

    def self.get_matching_repos(org, repo)
      begin
        return [$gh.repository("#{org}/#{repo}")]
      rescue Octokit::InvalidRepository
        return $lightly.get "#{org}/#{repo}" do
          $gh.org_repos(org, {:type => 'all'}).select {
            |ghrepo| (/#{repo}/ =~ ghrepo[:full_name].split('/')[1])
          }
        end
      end
    end
  end
end
