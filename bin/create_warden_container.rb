#!/usr/bin/env ruby

# Read JSON from stdin. The JSON should look like:
# {
#   "warden_socket_path": "/tmp/warden.sock",
#   "bind_mounts": [
#     {"src_path": "/tmp/foo", "dst_path": "/bar", mode: "rw"}
#   ],
#    "disk_limit": 100,
#    "memory_limit": 200,
#     "network": true,
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

begin
  warden_socket_path = config.fetch("warden_socket_path")
  container = Container.new(ConnectionProvider.new(warden_socket_path))
  create_network = config.fetch('network')
  container.create_container(
    config["bind_mounts"] || [],
    config.fetch("disk_limit"),
    config.fetch("memory_limit"),
    create_network)
rescue => e
  STDERR.puts("Failed to create a container with error:" + e.backtrace.join("\n"))
  exit 1
end

puts({
  handle: container.handle,
  host_port: container.network_ports["host_port"],
  container_port: container.network_ports["container_port"],
  console_host_port: container.network_ports["console_host_port"],
  console_container_port: container.network_ports["console_container_port"]
}.to_json)