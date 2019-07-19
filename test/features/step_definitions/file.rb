Then(/^(?:a|the) file(?: named)? "([^"]*)" should (not )?match:$/) do |file, negated, content|
    if negated
        expect(file).not_to have_file_content file_content_matching(content)
    else
        expect(file).to have_file_content file_content_matching(content)
    end
end


