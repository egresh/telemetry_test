require_relative "../lib/telemetry"

RSpec.describe "A Spawn Action" do
  include Telemetry::ActionUtils

  let(:spawn_action) { create_action(["-s", "spec/spawn_process.sh", "-l", "-a"]) }

  def spawn_csv_fields(log_entry)
    arr = CSV.parse(log_entry).flatten
    line = LogLine.new
    extract_csv_fields_common(arr, line)
    line
  end

  it "builds a spawn object and creates all csv log file entries" do
    silence do
      expect { spawn_action.execute }.not_to raise_error
    end

    csv = spawn_csv_fields(spawn_action.line_entry)

    expect(csv.process_name).to eq(spawn_action.process_name)
    expect(csv.command_line).to eq(spawn_action.command_line)
    expect(csv.process_id).to eq(spawn_action.process_id.to_s)
    expect(csv.username).to eq(spawn_action.username)
    expect(csv.timestamp).to eq(spawn_action.timestamp)
  end
end
