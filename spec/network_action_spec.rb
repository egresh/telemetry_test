require_relative "../lib/telemetry"

RSpec.describe "A Network Action" do
  include Telemetry::ActionUtils

  let(:network_action) { create_action(["-n", "www.google.com"]) }

  def network_csv_fields(log_entry)
    arr = CSV.parse(log_entry).flatten
    line = LogLine.new
    extract_csv_fields_common(arr, line)

    line.source_address = arr[5]
    line.source_port = arr[6]
    line.destination_address = arr[7]
    line.destination_port = arr[8]
    line.protocol = arr[9]
    line.data_transferred = arr[10]
    line
  end

  it "builds a network object and creates all csv log file entries" do
    allow(network_action).to receive(:connect)
    allow(network_action).to receive(:data_transferred).and_return(32768)
    allow(network_action).to receive(:source_address).and_return("192.168.10.10")
    allow(network_action).to receive(:source_port).and_return(52233)
    allow(network_action).to receive(:destination_address).and_return("192.168.10.11")
    allow(network_action).to receive(:destination_port).and_return(80)

    silence do
      expect { network_action.execute }.not_to raise_error
    end

    csv = network_csv_fields(network_action.line_entry)

    expect(csv.process_name).to eq(network_action.process_name)
    expect(csv.command_line).to eq(network_action.command_line)
    expect(csv.process_id).to eq(network_action.process_id.to_s)
    expect(csv.username).to eq(network_action.username)
    expect(csv.timestamp).to eq(network_action.timestamp)
    expect(csv.source_address).to eq(network_action.source_address)
    expect(csv.source_port).to eq(network_action.source_port.to_s)
    expect(csv.destination_address).to eq(network_action.destination_address)
    expect(csv.destination_port).to eq(network_action.destination_port.to_s)
    expect(csv.protocol).to eq(network_action.protocol)
    expect(csv.data_transferred).to eq(network_action.data_transferred.to_s)
  end
end
