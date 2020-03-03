require 'gh/ops'
require 'gh/ops/subcommand'

require 'rainbow/ext/string'

module Gh
  module Ops
    class Protection < SubCommand
      class_option :branch, :type => :string, :aliases => '-b',
        :desc => 'The Github branch pattern to work with',
        :default => 'master'

      desc 'get', 'get current branch protection rule'
      def get
        say "Getting branch protection rules for: #{options[:branch].color(:yellow)} on repos matching: #{options[:repo].color(:cyan)}"
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
      method_option :remove, :type => :boolean,
        :desc => 'Remove branch protection rules',
        :default => false
      method_option :approvals, :type => :numeric,
        :desc => 'Required number of approvals',
        :default => 1
      method_option :codeowners, :type => :boolean,
        :desc => 'Require review from Code Owners',
        :default => false
      method_option :stale, :type => :boolean,
        :desc => 'Dismiss stale pull request approvals when new commits are pushed',
        :default => true
      method_option :enforce, :type => :boolean,
        :desc => 'Enforce on admins',
        :default => true
      method_option :linear, :type => :boolean,
        :desc => 'Enforce linear history',
        :default => true
      method_option :force, :type => :boolean,
        :desc => 'Allow force pushes',
        :default => false
      method_option :deletions, :type => :boolean,
        :desc => 'Allow deletions',
        :default => false

      def set
        say "Setting branch protection rules for: #{options[:branch].color(:yellow)} on repos matching: #{options[:repo].color(:cyan)}"
        say 'Depending on the number of repos this may take a while...'
        say ''
        orgrepos = Gh::Ops.get_matching_repos(options[:org], options[:repo])

        protection_options = {
          :accept => 'application/vnd.github.luke-cage-preview+json',
          :required_pull_request_reviews => {
            :dismiss_stale_reviews => options[:stale],
            :require_code_owner_reviews => options[:codeowners],
            :required_approving_review_count => options[:approvals]
          },
          :enforce_admins => options[:enforce],
          :required_linear_history => options[:linear],
          :allow_force_pushes => options[:force],
          :allow_deletions => options[:deletions]
        }

        if yes?("Set branch protection on #{orgrepos.length} repos (yes or no)?")
          _set_branch_protection(orgrepos, options[:branch], protection_options)
          say 'Done!'
        else
          abort('Aborted')
        end

      end

      # Non-command functions
      no_commands {
        def _get_branch_protection(repos, branch)
          branch_protection = {}
          repos.each do |orgrepo|
            repo_branch_protection = $gh.branch_protection(orgrepo[:full_name], branch, :accept => 'application/vnd.github.luke-cage-preview+json')
            branch_protection[orgrepo[:full_name].to_sym] = repo_branch_protection
          end
          return branch_protection
        end

        def _set_branch_protection(repos, branch, protection_options)
          repos.each do |orgrepo|
            if options[:remove]
              $gh.unprotect_branch(orgrepo[:full_name].to_s, branch, :accept => 'application/vnd.github.luke-cage-preview+json')
            else
              $gh.protect_branch(orgrepo[:full_name].to_s, branch, protection_options)
            end
          end
        end
      }
    end
  end
end
