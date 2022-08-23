require_relative "../lib/telemetry"

RSpec.describe "File Actions" do
  include Telemetry::ActionUtils

  let(:create_file) { create_action(["-c", "tmp", "test_file", "file"]) }
  let(:create_directory) { create_action(["-c", "tmp", "test_dir", "directory"]) }
  let(:delete_file) { create_action(["-d", "tmp/test_file"]) }
  let(:delete_directory) { create_action(["-d", "tmp/test_dir"]) }
  let(:modify_file) { create_action(["-m", "tmp/test_file", "arg", "arg2", "arg3"]) }

  def file_csv_fields(log_entry)
    arr = CSV.parse(log_entry).flatten
    line = LogLine.new
    extract_csv_fields_common(arr, line)

    line.action_type = arr[5]
    line.full_path = arr[6]
    line
  end

  def validate_csv_entry(file_object)
    csv = file_csv_fields(file_object.line_entry)

    expect(csv.process_name).to eq(file_object.process_name)
    expect(csv.command_line).to eq(file_object.command_line)
    expect(csv.process_id).to eq(file_object.process_id.to_s)
    expect(csv.username).to eq(file_object.username)
    expect(csv.timestamp).to eq(file_object.timestamp)
    expect(csv.action_type).to eq(file_object.action_type.to_s)
    expect(csv.full_path).to eq(file_object.full_path)
  end

  context "Create File" do
    after(:context) do
      FileUtils.rmdir(File.join(APP_ROOT, "tmp/test_dir"))
      FileUtils.rm(File.join(APP_ROOT, "tmp/test_file"))
    end

    it "builds a create object with type file and creates all csv log file entries" do
      silence do
        expect { create_file.execute }.not_to raise_error
        expect { validate_csv_entry(create_file) }.not_to raise_error
      end
    end

    it "builds a create object with type directory and creates all csv log file entries" do
      silence do
        expect { create_directory.execute }.not_to raise_error
        expect { validate_csv_entry(create_directory) }.not_to raise_error
      end
    end
  end

  context "Delete File" do
    it "deletes a file object with type file and creates all csv log file entries" do
      silence do
        create_file.execute
        expect { delete_file.execute }.not_to raise_error
        expect { validate_csv_entry(delete_file) }.not_to raise_error
      end
    end

    it "deletes a file object with type directory and creates all csv log file entries" do
      silence do
        create_directory.execute
        expect { delete_directory.execute }.not_to raise_error
        expect { validate_csv_entry(delete_directory) }.not_to raise_error
      end
    end
  end

  context "Modify File" do
    it "modifies a file object and creates all csv log file entries" do
      silence do
        create_file.execute
        expect { modify_file.execute }.not_to raise_error
        expect { validate_csv_entry(modify_file) }.not_to raise_error
      end
    end
  end
end
