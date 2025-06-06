require "chef/mixin/shell_out"
require "chef/resource"
require "chef/version"
require_relative "../../api/stubs_for"
require_relative "../../errors"

module ::ChefSpec::Extensions::Chef::ResourceShellOut
  #
  # Defang shell_out and friends so it can never run.
  #
  if ChefSpec::API::StubsFor::HAS_SHELLOUT_COMPACTED.satisfied_by?(Gem::Version.create(Chef::VERSION))
    def shell_out_compacted(*args)
      return super unless $CHEFSPEC_MODE

      raise ChefSpec::Error::ShellOutNotStubbed.new(args: args, type: "resource", resource: self)
    end

    def shell_out_compacted!(*args)
      return super unless $CHEFSPEC_MODE

      shell_out_compacted(*args).tap(&:error!)
    end
  else
    def shell_out(*args)
      return super unless $CHEFSPEC_MODE

      raise ChefSpec::Error::ShellOutNotStubbed.new(args: args, type: "resource", resource: self)
    end
  end
end

module ::ChefSpec::Extensions::Chef::MixinShellOut
  #
  # Defang shell_out and friends so it can never run.
  #
  if ChefSpec::API::StubsFor::HAS_SHELLOUT_COMPACTED.satisfied_by?(Gem::Version.create(Chef::VERSION))
    def shell_out_compacted(*args)
      return super unless $CHEFSPEC_MODE

      raise ChefSpec::Error::LibraryShellOutNotStubbed.new(args: args, object: self)
    end

    def shell_out_compacted!(*args)
      return super unless $CHEFSPEC_MODE

      shell_out_compacted(*args).tap(&:error!)
    end
  else
    def shell_out(*args)
      return super unless $CHEFSPEC_MODE

      raise ChefSpec::Error::LibraryShellOutNotStubbed.new(args: args, object: self)
    end
  end
end

::Chef::Mixin::ShellOut.prepend(::ChefSpec::Extensions::Chef::MixinShellOut)
::Chef::Resource.prepend(::ChefSpec::Extensions::Chef::ResourceShellOut)
