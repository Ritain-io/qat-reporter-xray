Then(/^(?:a|the) file(?: named)? "([^"]*)" should (not )?match:$/) do |file, negated, content|
    if negated
        expect(file).not_to be_an_existing_file
    else
        expect(file).to be_an_existing_file
    end
end


