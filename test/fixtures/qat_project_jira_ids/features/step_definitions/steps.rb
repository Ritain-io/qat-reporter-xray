Given(/^some pre\-settings$/) do
  assert true
end

Given(/^some conditions$/) do
  assert true
end

When(/^some actions are made$/) do
  sleep(1)
  assert true
end

Then(/^a result is achieved$/) do
  assert true
end

Then(/^an expected result is not achieved$/) do
  assert false
end

When(/^action (.*) is made$/) do |action|
  sleep(1)
  assert true
end

Then(/^result (.*) is achieved$/) do |result|
  assert true
end

When(/^(?:some )?"(good|bad)" actions? (?:is|are) made$/) do |action|
  sleep(1)
  case action
  when 'good'
    assert true
  else
    assert false
  end
end

Then(/^"(good|bad)" result is achieved/) do |result|
  case result
  when 'good'
    assert true
  else
    assert false
  end
end