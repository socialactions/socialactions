begin
  require 'csv_builder'

  ActionView::Template.register_template_handler 'csvbuilder', ActionView::TemplateHandlers::CsvBuilder
rescue LoadError
end
