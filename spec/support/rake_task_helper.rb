module RakeTaskHelper
  def rake(task, args = [])
    with_rake_env { invoke(task, args) }
  end

private

  def application_tasks
    Rails.application.paths["lib/tasks"].to_a
  end

  def invoke(task, args)
    Rake::Task[task].invoke(*args)
  end

  def with_rake_env
    new_rake = Rake::Application.new
    old_rake = Rake.application
    Rake.application = new_rake

    # The Rails enviroment is already loaded so we define an
    # empty environment task to fufill the prerequisites.
    Rake::Task.define_task(:environment)

    # Load just the application tasks defined in `lib/tasks`
    application_tasks.each { |task| load(task) }

    yield
  ensure
    Rake.application = old_rake
  end
end
