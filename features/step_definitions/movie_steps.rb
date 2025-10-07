# Add a declarative step here for populating the DB with movies.

Given(/^the following movies exist:$/) do |movies_table|
    Movie.delete_all
    movies_table.hashes.each do |movie|
      # each returned element will be a hash whose key is the table header.
      # you should arrange to add that movie to the database here.
      Movie.create!(
        title: movie['title'],
        rating: movie['rating'],
        release_date: movie['release_date']
      )
    end
  end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/^I should see "(.*)" before "(.*)" in the movie list$/) do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  body = page.body
  a = body.index(e1)
  b = body.index(e2)
  expect(a).not_to be_nil, %Q("#{e1}" not found on page)
  expect(b).not_to be_nil, %Q("#{e2}" not found on page)
  expect(a).to be < b
end


# Make it easier to express checking or unchecking several boxes at once
#  "When I check only the following ratings: PG, G, R"

When(/I check the following ratings: (.*)/) do |list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  list.split(/\s*,\s*/).each { |r| check("ratings_#{r}") }
end

When(/I uncheck the following ratings: (.*)/) do |list|
  list.split(/\s*,\s*/).each { |r| uncheck("ratings_#{r}") }
end

Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  movie_list.split(/\s*,\s*/).each do |title|
    if no
      expect(page).not_to have_content(title)
    else
      expect(page).to have_content(title)
    end
  end  
end

Then(/^I should see all the movies$/) do
  # Make sure that all the movies in the app are visible in the table
  if page.has_css?('table#movies tbody tr')
    expect(page).to have_css('table#movies tbody tr', count: Movie.count)
  else
    Movie.pluck(:title).each { |t| expect(page).to have_content(t) }
  end    
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end
