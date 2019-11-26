require 'gh/ops/thorbase'

class SubCommand < Gh::Ops::ThorBase
  class << self
    def help(shell, subcommand = false)
      list = printable_commands(true, subcommand)
      Thor::Util.thor_classes_in(self).each do |klass|
        list += klass.printable_commands(false)
      end

      # Remove this line to disable alphabetical sorting
      # list.sort! { |a, b| a[0] <=> b[0] }

      # Add this line to remove the help-command itself from the output
      list.reject! {|l| l[0].split[1] == 'help'}

      if defined?(@package_name) && @package_name
        shell.say "#{@package_name} commands:"
      else
        shell.say 'Commands:'
      end

      shell.print_table(list, :indent => 2, :truncate => true)
      shell.say
      class_options_help(shell)

      # Add this line if you want to print custom text at the end of your help output.
      # (similar to how Rails does it)
      shell.say 'All commands can be run with -h (or --help) for more information.'
    end
  end

  def self.banner(command, namespace = nil, subcommand = false)
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
  end
end
