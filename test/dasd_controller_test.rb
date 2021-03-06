#!/usr/bin/env rspec

require_relative "./test_helper"

Yast.import "DASDController"

describe "Yast::DASDController" do
  describe "#IsAvailable" do
    it "returns true if .probe.disk contains DASDs" do
      expect(Yast::SCR).to receive(:Read).with(Yast.path(".probe.disk")).once
        .and_return(load_data("probe_disk_dasd.yml"))
      expect(Yast::DASDController.IsAvailable()).to eq(true)
    end
  end

  describe "#Write" do
    it "writes the dasd settings to the target (formating disks)" do
      # bnc 928388
      data = { "devices" => [{ "channel" => "0.0.0100", "diag" => false,
       "format" => true }], "format_unformatted" => true }

      allow(Yast::Mode).to receive(:normal).and_return(false)
      allow(Yast::Mode).to receive(:installation).and_return(true)
      allow(Yast::Mode).to receive(:autoinst).and_return(true)
      # speed up the test a bit
      allow(Yast::Builtins).to receive(:sleep)
      allow(Yast::DASDController).to receive(:ActivateDisk).and_return(0)
      expect(Yast::DASDController).to receive(:GetDeviceName).and_return("/dev/dasda")
      expect(Yast::SCR).to receive(:Execute).with(Yast::Path.new(".process.start_shell"),
        "/sbin/dasdfmt -Y -P 1 -b 4096 -y -r 10 -m 10 -f '/dev/dasda'")

      expect(Yast::DASDController.Import(data)).to eq(true)
      expect(Yast::DASDController.Write).to eq(true)
    end
  end
end
