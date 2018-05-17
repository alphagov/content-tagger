namespace :taxonomy do
  desc <<-DESC
    Performs all taxonomy health checks and reports any problems.
  DESC
  task health_checks: [:environment] do
    Taxonomy::HealthWarning.delete_all
    ContentTagger::Application.config_for(:health_checks)['metrics'].each do |metric|
      puts %(Name: #{metric['name']}; Arguments: #{(metric['arguments'] || []).map { |k, v| "#{k}: #{v}" }.join(', ')})
      klazz = "TaxonomyHealth::#{metric['class']}".constantize
      klazz.perform_async(metric['arguments'])
    end
  end
end
