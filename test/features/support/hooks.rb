#-*- encoding : utf-8 -*-

#Uncomment all necessary custom hooks

# BeforeAll do
#   # Your code here
# end

Before do |scenario|
  set_environment_variable 'VCR_CASSETTE_NAME', scenario.name.downcase.parameterize
end

# Around do |scenario, block|
#   # Your code here
#
#   #DON'T FORGET TO CALL THE SCENARIO'S BLOCK!!!!
#   block.call

#   # Your code here
# end

# After do |scenario|
#   # Your code here
# end

# AfterStep do |step|
#   # Your code here
# end

# at_exit do
#   # Your code here
# end