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
    { source_language: source_language, destination_language: destination_language }.merge(translation_params)
  end

  def translation_params
    return {} unless params.key?(:translation)

    params
      .require(:translation)
      .permit(:source_code, :source_language, :destination_language)
      .to_h
      .symbolize_keys
  end

  def source_language
    translation_params[:source_language] || "ruby"
  end

  def destination_language
    translation_params[:destination_language] || "js"
  end
end
