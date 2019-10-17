class Translation
  include ActiveModel::Model

  attr_accessor :input_code, :input_language, :output_language

  def output_code
    input_code
  end
end
