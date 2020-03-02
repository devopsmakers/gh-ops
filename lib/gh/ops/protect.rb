require 'gh/ops'
require 'gh/ops/subcommand'

require 'rainbow/ext/string'

module Gh
  module Ops
    class Protect < SubCommand
      class_option :branch, :type => :string, :aliases => '-b',
        :desc => 'The Github branch pattern to work with',
        :default => 'master'

      desc 'get', 'get current branch protection rule'
      def get
        say "Getting Branch protection rules for: #{options[:branch].color(:yellow)} on repos matching: #{options[:repo].color(:cyan)}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        rows = []
        branch_protection = _get_branch_protection(orgrepos, options[:branch])
        branch_protection.each do |repo, branch_rules|
          if branch_rules
            approvals = <<-APPROVALS.chomp
Number of Reviews: #{branch_rules[:required_pull_request_reviews][:required_approving_review_count]}
Dismiss Stale:     #{branch_rules[:required_pull_request_reviews][:dismiss_stale_reviews]}
Require CODEOWNER: #{branch_rules[:required_pull_request_reviews][:require_code_owner_reviews]}
APPROVALS

            enforce_admins = branch_rules[:enforce_admins][:enabled]
            linear_history = branch_rules[:required_linear_history][:enabled]
            force_push = branch_rules[:allow_force_pushes][:enabled]
            allow_delete = branch_rules[:allow_deletions][:enabled]

            rows << [repo, approvals, enforce_admins, linear_history, force_push, allow_delete]
          else
            rows << [repo, 'N/A    ', 'N/A         ', 'N/A         ', 'N/A     ', 'N/A       ']
          end
        end

        say Gh::Ops.data_table(['Repository', 'Approvals', 'Include Admins', 'Linear History', 'Force Pushes', 'Allow Deletion'], rows)
      end

      desc 'set', 'set a branch protection rule'
      def set
        p 'set perms'
      end

      # Non-command functions
      no_commands {
        def _get_branch_protection(repos, branch)
          branch_protection = {}
          repos.each do |orgrepo|
            repo_branch_protection = $gh.branch_protection(orgrepo[:full_name], branch, :accept => "application/vnd.github.luke-cage-preview+json")
            branch_protection[orgrepo[:full_name].to_sym] = repo_branch_protection
          end
          return branch_protection
        end
      }
    end
  end
end
