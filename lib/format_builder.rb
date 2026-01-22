class FormatBuilder
  PLACEHOLDERS = %w[type identifier initials title].freeze

  def initialize(format)
    @format = format
  end

  def build(values)
    result = @format.dup

    # Replace placeholders with values.
    PLACEHOLDERS.each do |key|
      result.gsub!("%#{key}%", values[key.to_sym]&.to_s || "")
    end

    # Collapse consecutive separators.
    result.gsub!(/-+/, "-")
    result.gsub!(/\/+/, "/")
    result.gsub!(/_+/, "_")

    result
  end
end
