require 'gh/ops'
require 'gh/ops/subcommand'

module Gh
  module Ops
    class Comment < SubCommand
      desc 'get', 'get permissions on a repo'
      def get
        p 'get perms'
      end
      desc 'set', 'set permissions on a repo'
      def set
        p 'set perms'
      end
    end
  end
end
