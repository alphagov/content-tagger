module RakeTaskHelper
  def rake(task, args = [])
    Rake::Task[task].invoke(*args)
    Rake::Task[task].reenable
  end
end
