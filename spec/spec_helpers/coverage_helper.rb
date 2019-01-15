require 'coveralls'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter
])

SimpleCov.at_exit do
  SimpleCov.result.format!

  if SimpleCov.result.covered_percent < 100
    puts "\n\e[31m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\e[0m\n"
    puts "\e[31mConverage is under 100%. See `coverage/index.html`\e[0m\n"
    puts "\e[31m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\e[0m\n\n"
    abort('Test failed.')
  end
end

SimpleCov.start
