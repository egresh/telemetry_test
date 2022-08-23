require_relative "../lib/telemetry"

RSpec.describe "Errors" do
  include Telemetry::ActionUtils

  context "when given a single parameter requesting an action" do
    let(:action_s) { create_action(["-s"]) }
    let(:action_n) { create_action(["-n"]) }
    let(:action_c) { create_action(["-c"]) }
    let(:action_d) { create_action(["-d"]) }
    let(:action_m) { create_action(["-m"]) }

    it "-s, -n, -c, -d, -m will exit with a status 0" do
      expect { silence { action_n } }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end

      expect { silence { action_s } }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end

      expect { silence { action_c } }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end

      expect { silence { action_d } }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end

      expect { silence { action_m } }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end
    end
  end

  context "when given intentional error conditions, the" do
    let(:action_s) { create_action(["-s", "asdfasdf"]) }
    let(:action_n) { create_action(["-n", "hostname_that_wont_resolve_asdfasdfsdfsdf"]) }
    let(:action_c) { create_action(["-c", "/", "foo", "directory"]) }
    let(:action_d) { create_action(["-d", "/this_is_a_file_that_does_not_exist"]) }
    let(:action_m) { create_action(["-m", "/this_is_a_file_that_does_not_exist"]) }

    it "spawn action generates an exception" do
      expect { action_s.execute }.to raise_error(StandardError)
    end

    it "network action generates an exception" do
      expect { action_n.execute }.to raise_error(StandardError)
    end

    it "create action generates an exception" do
      expect { action_c.execute }.to raise_error(StandardError)
    end

    it "delete action generates an exception" do
      expect { action_d.execute }.to raise_error(StandardError)
    end

    it "modify action generates an exception" do
      expect { action_m.execute }.to raise_error(StandardError)
    end
  end
end
