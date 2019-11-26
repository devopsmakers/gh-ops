require 'gh/ops'
require 'gh/ops/subcommand'

require 'terminal-table'

module Gh
  module Ops
    class Permissions < SubCommand
      class_option :identity, :type => :string, :aliases => '-i',
        :desc => 'The Github user or team to work with',
        :default => $gh.user()[:login]

      desc 'get', 'get permissions on a repo'
      def get
        say "Getting permissions for: #{options[:identity]} on repos matching: #{options[:repo]}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        rows = []
        repo_perms = _get_permissions(orgrepos, options[:identity])
        repo_perms.each do |repo, perm|
          rows << [repo, perm]
        end

        say Gh::Ops.data_table(['Repository', 'Permission'], rows)
      end

      desc 'set', 'set permissions on a repo'
      method_option :permission, :type => :string, :aliases => '-p',
        :desc => 'Permission to set on repositories [none, read or write]',
        :default => 'read'
      def set
        say "Setting permissions for: #{options[:identity]} on repos matching: #{options[:repo]} to #{options[:permission]}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        rows = []
        repos_to_fix = []
        repo_perms = _get_permissions(orgrepos, options[:identity])
        repo_perms.each do |repo, perm|
          rows << [repo, perm]
          if perm != options[:permission]
            repos_to_fix << repo
          end
        end

        if yes?("Set #{options[:permission]} permission on #{repos_to_fix.length} repos (yes or no)?")
          _set_permissions(repos_to_fix, options[:identity], options[:permission])
          say 'Done!'
        else
          abort('Aborted')
        end

      end

      # Non-command functions
      no_commands {
        def _get_permissions(repos, identity)
          repo_perms = {}
          repos.each do |orgrepo|
            repo_perm = $gh.permission_level(orgrepo[:full_name], identity, :accept => "application/vnd.github.beta+json")
            repo_perms[orgrepo[:full_name].to_sym] = repo_perm[:permission]
          end
          return repo_perms
        end

        def _set_permissions(repos, identity, permission)
          case permission
          when "read"
            perm = "pull"
          when "write"
            perm = "push"
          else
            perm = "none"
          end
          repos.each do |repo|
            if perm == "none"
              $gh.remove_collaborator(repo.to_s, identity)
            else
              $gh.add_collaborator(repo.to_s, identity, :permission => perm)
            end
          end
        end
      }
    end
  end
end
