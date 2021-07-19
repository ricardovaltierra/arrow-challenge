# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User creates arrow', type: :system do 
  
  before do
    @user_1 = create :user
    @user_2 = create :user
    visit new_user_session_path
    fill_in 'user_email', with: @user_1.email
    fill_in 'user_password', with: @user_1.password
    find_button('Log in').trigger(:click)
    visit root_path
    page.save_screenshot(full: true)
    find_link('Create arrow').trigger(:click)
  end

  scenario 'with the required fields properly set' do
    select @user_2.name, from: 'arrow_owner_id'
    fill_in 'arrow_description', with: 'This is a quite long reason to give for an arrow!'
    find_button('send'.upcase).trigger(:click)
    
    expect(page).to have_text 'Great! Your arrow has been successfully sent!'
  end

  scenario 'with no partner selected from dropdown' do
    fill_in 'arrow_description', with: 'This is a quite long reason to give for an arrow!'
    find_button('send'.upcase).trigger(:click)

    expect(page).to have_content 'Owner must exist'
  end

  scenario 'with reason typed with less than 30 characters' do
    select @user_2.name, from: 'arrow_owner_id'
    fill_in 'arrow_description', with: 'This is short...'
    find_button('send'.upcase).trigger(:click)

    expect(page).to have_content 'Description is too short (minimum is 30 characters)'
  end

  scenario 'with no reason typed on textarea' do
    select @user_2.name, from: 'arrow_owner_id'
    find_button('send'.upcase).trigger(:click)
    page.save_screenshot(full: true)

    expect(page).to have_text "Description can't be blank"
    expect(page).to have_content 'Description is too short (minimum is 30 characters)'
  end

  scenario 'with no partner selected neither reason typed' do
    find_button('send'.upcase).trigger(:click)

    expect(page).to have_text "Description can't be blank"
    expect(page).to have_content 'Description is too short (minimum is 30 characters)'
    expect(page).to have_text 'Owner must exist'
  end

  scenario "but instead, declines and clicks 'CANCEL'" do
    find_link('cancel'.upcase).trigger(:click)

    expect(page).to have_no_content 'Great! Your arrow has been successfully sent!'
  end

  scenario 'but instead, declines and clicks top-right modal corner' do
    click_button 'Close'

    expect(page).to have_no_content 'Great! Your arrow has been successfully sent!'
  end
end
