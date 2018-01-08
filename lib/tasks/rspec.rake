if defined? RSpec # otherwise fails on non-live environments
  task(:spec).clear
  desc "Run all specs/features in spec directory"
  RSpec::Core::RakeTask.new(:spec => 'db:test:prepare') do |t|
    t.pattern = './spec/**/*{_spec.rb,.feature}'
  end

  namespace :spec do
    desc "Run the code examples in spec/acceptance"
    RSpec::Core::RakeTask.new(:acceptance => 'db:test:prepare') do |t|
      t.pattern = './spec/features/**/*{_spec.rb,.feature}'
    end
  end
end
