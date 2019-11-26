require 'thor'
require 'git'

module Gh
  module Ops

    # Set defaults here.
    class ThorBase < Thor
      include Thor::Actions

      def self.source_root
        File.dirname(__FILE__)
      end

      def self._get_this_repo
        repo_regex = /^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$/
        begin
          g = Git.open('.')
        rescue
          return nil
        end
        r = g.remote('origin').url.match(repo_regex)
        return ["#{r[4]}", "#{r[5]}"]
      end

      class_option :org, :type => :string, :aliases => '-o',
        :default => _get_this_repo()[0],
        :desc => 'The Github organization you want to work in'

      class_option :repo, :type => :string, :aliases => '-r',
        :default => _get_this_repo()[1],
        :desc => 'The repo name pattern to match you want to work on. Example: "^tf-aws-.*"'
    end

  end
end
