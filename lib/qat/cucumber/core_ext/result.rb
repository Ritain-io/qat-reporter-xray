require 'cucumber/core/test/result'

#Patch for Cucumber::Core::Test::Result::Unknown to implement methods used by the formatters
#@since 1.1.0
class Cucumber::Core::Test::Result::Unknown

  #Dummy function
  def with_appended_backtrace(_)
    ''
  end

  #Dummy function
  def with_filtered_backtrace(_)
    ''
  end
end
