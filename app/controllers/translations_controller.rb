class TranslationsController < ApplicationController
  helper_method :translation

  def new; end
  def create
    render :new
  end

private

  def translation
    @translation ||= Translation.new(**translation_params_with_defaults)
  end

  def translation_params_with_defaults
    { input_language: input_language, output_language: output_language }.merge(translation_params)
  end

  def translation_params
    return {} unless params.key?(:translation)

    params
      .require(:translation)
      .permit(:input_code, :input_language, :output_language)
      .to_h
      .symbolize_keys
  end

  def input_language
    translation_params[:input_language] || "ruby"
  end

  def output_language
    translation_params[:output_language] || "js"
  end
end
