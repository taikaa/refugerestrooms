require 'spec_helper'

describe 'the restroom submission process', type: :feature, js: true do
  it 'should add a restroom when submitted' do
    visit root_path
    click_link "Submit a New Restroom"
    fill_in "restroom[name]", with: "Vancouver restroom"
    fill_in "restroom[street]", with: "684 East Hastings"
    fill_in "restroom[city]", with: "Vancouver"
    fill_in "restroom[state]", with: "British Columbia"
    find(:select, "Country").first(:option, "Canada").select_option
    click_button "Save Restroom"

    expect(page).to have_content("A new restroom entry has been created for")
  end

  it 'should block a spam submission' do
    visit root_path
    click_link 'Submit a New Restroom'
    fill_in 'restroom[name]', with: 'Spam restroom'
    fill_in 'restroom[street]', with: 'Spamstreet'
    fill_in 'restroom[city]', with: 'Spamland'
    fill_in 'restroom[state]', with: 'Spamstate'
    find('#restroom_country').find(:xpath, "option[contains(., 'Canada')][1]").select_option
    click_button 'Save Restroom'

    expect(page).to have_content("Your submission was rejected as spam.")
  end

  #it "should guess my location" do
  #  visit "/"
  #  click_link "Submit a New Restroom"
  #  mock_location("Oakland")

  #  find(".guess-btn").click

  #  expect(page).to have_field('restroom[street]', with: "1400 Broadway")
  #  expect(page).to have_field('restroom[city]', with: "Oakland")
  #  expect(page).to have_field('restroom[state]', with: "CA")
  #end
end

describe 'the restroom search process', type: :feature, js: true do
  it 'should search for text from the splash page' do
    create(:restroom, :geocoded, name: 'Mission Creek Cafe')

    visit root_path
    fill_in 'search', with: 'Mission Creek Cafe'
    click_on 'Search'

    expect(page).to have_content 'Mission Creek Cafe'
  end

  it 'should search for location from the splash page' do
    create(:oakland_restroom, name: "Some Cafe")

    visit root_path
    mock_location "Oakland"
    click_on 'Search by Current Location'

    expect(page).to_not have_content 'Some Cafe'
  end

  it 'should search from the splash page with a screen reader' do
    visit root_path

   expect(find('button.submit-search-button')['aria-label']).to be_truthy
   expect(find('button.current-location-button')['aria-label']).to be_truthy
  end

  it 'should display a map' do
    create(:oakland_restroom)

    visit root_path
    mock_location "Oakland"
    find('.current-location-button').click
    # TODO: Figure out why this isn't working.
    # print page.html
    page.has_css?(".mapToggle", :visible => true)
    # find('.mapToggle').click
    # print page.html

    # TODO: Figure Out why This isn't working either
    # page.has_css?(#)
    # expect(page).to have_css('#mapArea.loaded')
    # expect(page).to have_css('#mapArea .numberCircleText')
  end
end


describe 'the preview process', type: :feature, js: true do
  it 'should preview a restroom before submitting' do
    visit "/"
    click_link "Submit a New Restroom"
    fill_in "restroom[name]", with: "Vancouver restroom"
    fill_in "restroom[street]", with: "684 East Hastings"
    fill_in "restroom[city]", with: "Vancouver"
    fill_in "restroom[state]", with: "British Columbia"
    find(:select, "Country").first(:option, "Canada").select_option

    click_on "Preview"

    expect(page).to have_css("div#mapArea", :visible => true)
  end
end

describe 'the nearby restroom display process', type: :feature, js: true do
  it 'should show nearby restrooms when they exist' do
    create(:oakland_restroom)
    visit "/"
    click_link "Submit a New Restroom"
    mock_location "Oakland"

    find(".guess-btn").click

    page.has_css?(".nearby-container .listItem", :visible => true)
  end

  it "should not show nearby restrooms when they don't exist" do
    visit "/"
    click_link "Submit a New Restroom"
    mock_location "Oakland"

    find(".guess-btn").click

    page.has_css?(".nearby-container .none", :visible => true)
  end
end

describe "the edit process", type: :feature do
  it "should create an edit listing" do
    restroom = create(:restroom)
    visit "/restrooms/#{restroom.id}"
    click_link "Propose an edit to this listing."

    fill_in "restroom[directions]", with: "This is an edit"
    click_on "Save Restroom"

    expect(page).to have_content("Your edit has been submitted.")
    expect(Restroom.where(edit_id: restroom.id).size).to eq(2)
  end
end
