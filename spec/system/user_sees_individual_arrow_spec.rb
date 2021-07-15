require 'system_helper'

RSpec.describe 'User sees an individual arrow', type: :system do
  
  before do
    @user_1 = create :user
    @user_2 = create :user
    
    visit new_user_session_path

    fill_in 'user_email', with: @user_1.email
    fill_in 'user_password', with: @user_1.password
    find_button('Log in').trigger(:click)
    visit root_path

    find_link('Create arrow').trigger(:click)
    select @user_2.name, from: 'arrow_owner_id'
    fill_in 'arrow_description', with: 'This is a quite long reason to give for an arrow!'
    find_button('send'.upcase).trigger(:click)

    click_link @user_1.email
    find_button('Log out').trigger(:click)
    visit new_user_session_path

    fill_in 'user_email', with: @user_2.email
    fill_in 'user_password', with: @user_2.password
    find_button('Log in').trigger(:click)
  end

  scenario 'clicking on the one appearing on home page' do
    visit root_path
    find_link('More info').trigger(:click)
    page.save_screenshot(full: true)

    expect(page).to have_content "BY WHO: #{@user_1.name}"
    expect(page).to have_content 'This is a quite long reason to give for an arrow!'
  end
end
