# AGENTS.md

This file provides guidance to AI agents

## Project Overview

ChefSpec is a unit testing framework for Chef cookbooks. It runs cookbooks locally with resource actions disabled, enabling fast feedback without requiring virtual machines or cloud servers.

## Common Commands

```bash
# Run all tests (unit + acceptance)
bundle exec rake

# Run only unit tests
bundle exec rake unit

# Run only acceptance tests
bundle exec rake acceptance

# Run a single acceptance test example
bundle exec rake acceptance:<example_name>  # e.g., acceptance:custom_resource

# Run a specific unit test file
bundle exec rspec spec/unit/<file>_spec.rb

# Lint with Cookstyle (ChefStyle)
bundle exec rake style
```

## Architecture

### Runners

- **SoloRunner** (`lib/chefspec/solo_runner.rb`): The primary runner that simulates a Chef Solo run. Creates a `Chef::Client`, loads Fauxhai data, and converges recipes without actually executing resource actions.
- **ServerRunner** (`lib/chefspec/server_runner.rb`): Extends SoloRunner to simulate a Chef Server environment using chef-zero.
- **Runner** (`lib/chefspec/runner.rb`): Alias for SoloRunner for backward compatibility.

### API Layer

`lib/chefspec/api/` contains modules that provide the RSpec DSL:

- **Core** (`api/core.rb`): Provides `platform`, `recipe`, `step_into`, `*_attributes`, `chefspec_options` helpers. Sets up `chef_run`, `chef_runner`, `chef_node` let variables.
- **Stubs** (`api/stubs.rb`): `stub_command`, `stub_search`, `stub_data_bag`, `stub_data_bag_item`
- **StubsFor** (`api/stubs_for.rb`): `stubs_for_resource`, `stubs_for_provider`, `stubs_for_current_value`
- **RenderFile** (`api/render_file.rb`): `render_file` matcher
- **Notifications** (`api/notifications.rb`): `notify` matcher
- **Subscriptions** (`api/subscriptions.rb`): `subscribe_to` matcher

### Matchers

`lib/chefspec/matchers/` contains RSpec matchers:

- **ResourceMatcher**: Dynamically generated `action_resource(name)` matchers (e.g., `create_file`, `install_package`)
- **RenderFileMatcher**: For testing file content from template/file/cookbook_file resources
- **NotificationsMatcher** / **SubscribesMatcher**: For testing resource notifications

### Extensions

`lib/chefspec/extensions/` patches Chef classes to:
- Disable actual resource execution (actions become no-ops)
- Track performed actions for matcher verification
- Handle shell_out stubbing
- Support `step_into` for custom resources

### Stubs System

`lib/chefspec/stubs/` provides registries and stub objects for:
- Shell commands (guard clauses)
- Search queries
- Data bags and data bag items

## Test Structure

- **Unit tests** (`spec/unit/`): Test ChefSpec's own internals
- **Acceptance tests** (`examples/`): Each subdirectory is a mini-cookbook testing a specific feature. Run via `rake acceptance:<dirname>`

## Key Patterns

Resource matchers follow `action_resource(name)` pattern:
```ruby
it { is_expected.to create_file('/etc/config') }
it { is_expected.to install_package('nginx').with(version: '1.0') }
```

Testing custom resources requires `step_into`:
```ruby
step_into :my_custom_resource
# or
ChefSpec::SoloRunner.new(step_into: ['my_custom_resource'])
```
