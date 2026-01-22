require_relative "../lib/format_builder"

RSpec.describe FormatBuilder do
  describe "#build" do
    it "replaces all placeholders with values" do
      builder = FormatBuilder.new("%type%/%identifier%-%initials%-%title%")

      result = builder.build(
        type: "feature",
        identifier: "DEV-123",
        initials: "mw",
        title: "my-branch-title"
      )

      expect(result).to eq("feature/DEV-123-mw-my-branch-title")
    end

    it "handles nil values" do
      builder = FormatBuilder.new("%type%/%identifier%-%initials%-%title%")

      result = builder.build(
        type: "feature",
        identifier: "DEV-123",
        initials: nil,
        title: "my-branch-title"
      )

      expect(result).to eq("feature/DEV-123-my-branch-title")
    end

    it "handles missing keys" do
      builder = FormatBuilder.new("%type%/%identifier%-%title%")

      result = builder.build(
        type: "bugfix",
        identifier: "DEV-456",
        title: "fix-something"
      )

      expect(result).to eq("bugfix/DEV-456-fix-something")
    end

    it "supports custom formats" do
      builder = FormatBuilder.new("%identifier%-%title%")

      result = builder.build(
        identifier: "DEV-789",
        title: "simple-branch"
      )

      expect(result).to eq("DEV-789-simple-branch")
    end

    it "collapses consecutive separators" do
      builder = FormatBuilder.new("%type%/%identifier%-%initials%-%title%")

      result = builder.build(
        type: nil,
        identifier: "DEV-123",
        initials: nil,
        title: "my-branch"
      )

      expect(result).to eq("/DEV-123-my-branch")
    end
  end
end
