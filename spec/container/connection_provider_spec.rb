require "spec_helper"
require "container/connection_provider"

describe ConnectionProvider do
  let(:socket_path) { "/tmp/warden.sock.notreally" }
  let(:connection_name) { "connection_name" }
  let(:connected) { false }
  let(:response) { "response" }
  let(:connection) do
    double("fake connection",
      :name => connection_name,
      :connect => response,
      :connected? => connected
    )
  end

  subject(:connection_provider) { described_class.new(socket_path) }

  describe "#get" do
    before do
      EventMachine::Warden::FiberAwareClient.stub(:new).with(socket_path).and_return(connection)
    end

    context "when connection is cached" do
      before do
        @connection = connection_provider.get(connection_name)
      end

      context "when connection is connected" do
        let(:connected) { true }
        it "uses cached connection" do
          expect(connection_provider.get(connection_name)).to equal(@connection)
        end
      end

      context "when connection is not connected" do
        let(:connected) { false }
        it "creates new connection" do
          EventMachine::Warden::FiberAwareClient.should_receive(:new).with(socket_path).and_return(connection)
          connection_provider.get(connection_name)
        end
      end
    end

    context "when connection is not cached" do
      let(:connected) { false }
      before do
        EventMachine::Warden::FiberAwareClient.should_receive(:new).with(socket_path).and_return(connection)
      end

      it "creates a new connection and caches it" do
        connection_provider.get(connection_name)
        expect(connection_provider.get(connection_name)).to eq(connection)
      end

      context "if connection fails" do
        let(:connection) { double("failing connection")}

        it "raises an error" do
          connection.stub(:create).and_raise("whoops")
          expect {
            connection_provider.get(connection_name)
          }.to raise_error
        end
      end
    end
  end

  describe "keeping track of connections" do
    describe "#close_all" do
      let(:connection_name_two) { "connection_name_two" }

      let(:connection_two) do
        double("fake connection 2",
          :name => connection_name_two,
          :connect => response,
          :disconnect => "disconnecting",
          :connected? => connected)
      end

      before do
        EventMachine::Warden::FiberAwareClient.should_receive(:new).
          with(socket_path).ordered.and_return(connection)
        EventMachine::Warden::FiberAwareClient.should_receive(:new).
          with(socket_path).ordered.and_return(connection_two)

        connection_provider.get(connection_name)
        connection_provider.get(connection_name_two)
      end

      it "closes all connections" do
        connection.should_receive(:disconnect)
        connection_two.should_receive(:disconnect)

        connection_provider.close_all
      end

      it "removes the connections from the cache" do
        connection.stub(:disconnect)
        connection_two.stub(:disconnect)
        connection_provider.close_all

        EventMachine::Warden::FiberAwareClient.should_receive(:new).ordered.
          with(socket_path).and_return(connection)

        connection_provider.get(connection_name)
      end
    end
  end

end
