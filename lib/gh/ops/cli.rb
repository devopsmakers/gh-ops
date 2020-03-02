require 'gh/ops'
require 'gh/ops/permissions'
require 'gh/ops/protect'
require 'gh/ops/comment'
require 'gh/ops/gist'
require 'gh/ops/status'
require 'gh/ops/review'

require 'thor'
require 'git'

module Gh
  module Ops
    class CLI < Thor
      desc 'permissions', 'Operate on repository permissions'
      subcommand 'permissions', Permissions

      desc 'protect', 'Manage branch protection rules'
      subcommand 'protect', Protect

      desc 'comment', 'Create, update and delete issue comments'
      subcommand 'comment', Comment

      desc 'gist', 'Create, update and delete gists'
      subcommand 'gist', Gist

      desc 'status', 'Manage a status check on a PR'
      subcommand 'status', Status

      desc 'review', 'Manage a review state on a PR'
      subcommand 'review', Review
    end
  end
end
