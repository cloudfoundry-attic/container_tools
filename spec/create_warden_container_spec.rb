require "spec_helper"

require "container/connection_provider"
require "container/container"
require "tempfile"
require "json"
require "open3"

describe "Creating a new container from shell command", type: :integration, requires_warden: true do
  let(:warden_socket_path) { "/tmp/warden.sock" }
  let(:warden_container_path) { "/tmp/warden/containers" }
  let(:cmd) {"bin/create_warden_container.sh"}

  it "creates a warden container" do
    configs = {
      warden_socket_path: warden_socket_path,
      bind_mounts: [
        {src_path: "/vagrant", dst_path: "/var/a", mode: "ro"}
      ],
      memory_limit: 100,
      disk_limit: 200,
      network: true,
    }

    Open3.popen3(cmd) do |stdin, out, error, wait_th|
      stdin << configs.to_json
      stdin.close
      expect(wait_th.value.exitstatus).to eq(0)
      expect(error.read).to be_empty
      json_output = JSON.parse(out.read)
      handle = json_output.fetch('handle')

      expect(Dir.entries(warden_container_path)).to include(handle)
      expect(json_output.fetch("host_port")).to be_an_instance_of(Fixnum)
      expect(json_output.fetch("container_port")).to be_an_instance_of(Fixnum)
      expect(json_output.fetch("console_container_port")).to be_an_instance_of(Fixnum)
      expect(json_output.fetch("console_host_port")).to be_an_instance_of(Fixnum)

      container = Container.new(ConnectionProvider.new(warden_socket_path))
      container.handle = handle
      container.destroy!

      expect(Dir.entries(warden_container_path)).not_to include(handle)
    end
  end


  it "prints out the error message in STDERR when it fails" do
    invalid_configs = {a: 1}
    Open3.popen3(cmd) do |stdin, out, error, wait_th|
      stdin << invalid_configs.to_json
      stdin.close
      expect(wait_th.value.exitstatus).to eq(1)
      expect(error.read).to match(/Failed to create/)
      expect(out.read).to be_empty
    end
  end
end