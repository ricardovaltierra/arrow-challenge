require 'system_helper'

RSpec.describe 'User sees all her arrows', type: :system do

  before do
    @user_1 = create :user
    @user_2 = create :user

    visit new_user_session_path

    fill_in 'user_email', with: @user_1.email
    fill_in 'user_password', with: @user_2.password
    click_button 'Log in'
    visit root_path

    3.times do |i|
      click_link 'Create arrow'
      select @user_2.name, from: 'arrow_owner_id'
      fill_in 'arrow_description', with: "This is the reason ##{i}to give for an arrow!"
      click_button 'send'.upcase
    end
    
    click_link @user_1.email
    click_button 'Log out'
    visit new_user_session_path

    fill_in 'user_email', with: @user_2.email
    fill_in 'user_password', with: @user_2.password
    click_button 'Log in'
  end

  scenario 'appearing in the home page' do
    visit root_path
    page.save_screenshot(full: true)
    
    cards = page.all('div', id: /arrow[0-9]+Card/).count
      
    expect(cards).to eql 3
  end
end
