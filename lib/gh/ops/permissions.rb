require 'gh/ops'
require 'gh/ops/subcommand'

require 'rainbow/ext/string'

module Gh
  module Ops
    class Permissions < SubCommand
      class_option :user, :type => :string, :aliases => '-u',
        :desc => 'A Github user to work with',
        :default => $gh.user()[:login]
      class_option :team, :type => :string, :aliases => '-t',
        :desc => 'A Github team to work with',
        :default => false

      desc 'get', 'get permissions on a repo'
      def get
        say "Getting permissions for: #{options[:team] ? options[:team].color(:yellow) : options[:user].color(:yellow)} on repos matching: #{options[:repo].color(:cyan)}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        rows = []
        repo_perms = _get_permissions(orgrepos, options[:user], options[:team])
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
        say "Setting permissions for: #{options[:user].color(:yellow)} on repos matching: #{options[:repo].color(:cyan)} to #{options[:permission].color(:red)}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        rows = []
        repos_to_fix = []
        repo_perms = _get_permissions(orgrepos, options[:user], options[:team])
        repo_perms.each do |repo, perm|
          rows << [repo, perm]
          if perm != options[:permission]
            repos_to_fix << repo
          end
        end

        if yes?("Set #{options[:permission]} permission on #{repos_to_fix.length} repos (yes or no)?")
          _set_permissions(repos_to_fix, options[:user], options[:team], options[:permission])
          say 'Done!'
        else
          abort('Aborted')
        end

      end

      # Non-command functions
      no_commands {
        def _team_id(org, team_name)
          teams = Gh::Ops.get_org_teams(org)
          return teams.find{ |team| team[:name] == team_name || team[:slug] == team_name }[:id]
        end

        def _get_permissions(repos, user, team_name)
          repo_perms = {}
          repos.each do |orgrepo|
            if team_name
              team_id = _team_id(orgrepo[:owner][:login], team_name)
              repo_perm = {}
              repo_perm[:permission] = 'none'
              team_repo = Gh::Ops.get_team_repos(orgrepo[:owner][:login], team_id).find{ |teamrepo| teamrepo[:full_name] == orgrepo[:full_name] }
              unless team_repo.nil?
                if team_repo[:permissions][:pull]
                  repo_perm[:permission] = 'read'
                  if team_repo[:permissions][:push]
                    repo_perm[:permission] = 'write'
                    if team_repo[:permissions][:admin]
                      repo_perm[:permission] = 'admin'
                    end
                  end
                end
              end
            else
              repo_perm = $gh.permission_level(orgrepo[:full_name], user, :accept => "application/vnd.github.beta+json")
            end
            repo_perms[orgrepo[:full_name].to_sym] = repo_perm[:permission]
          end
          return repo_perms
        end

        def _set_permissions(repos, user, team_name, permission)
          case permission
          when "admin"
            perm = "admin"
          when "read"
            perm = "pull"
          when "write"
            perm = "push"
          else
            perm = "none"
          end
          repos.each do |repo|
            if team_name
              team_id = _team_id(repo.to_s.split('/')[0], team_name)
              if perm == "none"
                $gh.remove_team_repository(team_id, repo.to_s)
              else
                $gh.add_team_repository(team_id, repo.to_s, :permission => perm)
              end
            else
              if perm == "none"
                $gh.remove_collaborator(repo.to_s, identity)
              else
                $gh.add_collaborator(repo.to_s, identity, :permission => perm)
              end
            end
          end
        end
      }
    end
  end
end
