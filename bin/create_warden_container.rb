#!/usr/bin/env ruby

# Read JSON from stdin. The JSON should look like:
# {
#   "warden_socket_path": "/tmp/warden.sock",
#   "bind_mounts": [
#     {"src_path": "/tmp/foo", "dst_path": "/bar", mode: "rw"}
#   ]
# }
#
# Then create a container with the specified bind mounts set up.
# Prints JSON to stdout that looks like:
# {
#   "handle": "abc123"
# }

require "json"

$:.unshift(File.expand_path("../../lib", __FILE__))
require "container/container"
require "container/connection_provider"

config = JSON.parse(STDIN.read)
warden_socket_path = config.fetch("warden_socket_path")
container = Container.new(ConnectionProvider.new(warden_socket_path))
create_network = config.fetch('network')

asdasd = container.create_container(
  config.fetch("bind_mounts"),
  config.fetch("disk_limit"),
  config.fetch("memory_limit"),
  create_network)

puts({
  handle: container.handle,
  network: container.network_ports
}.to_json)