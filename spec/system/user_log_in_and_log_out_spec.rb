# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User Log in', type: :system do
  before do
    @user = create :user
    visit new_user_session_path
  end

  scenario 'valid with the right credentials' do
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    find_button('Log in').trigger(:click)

    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_text "Hi #{@user.name}"
    expect(page).to have_content @user.email
    expect(page).to have_current_path root_path
  end

  scenario 'invalid with unregistered account' do
    fill_in 'user_email', with: Faker::Internet.email
    fill_in 'user_password', with: 'A123pass'
    find_button('Log in').trigger(:click)

    expect(page).to have_no_text 'Signed in successfully.'
    expect(page).to have_text 'Invalid Email or password.'
    expect(page).to have_no_button 'Log out'
  end

  scenario 'invalid with invalid password' do
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: 'FakePassword'
    find_button('Log in').trigger(:click)

    expect(page).to have_no_text 'Signed in successfully.'
    expect(page).to have_text 'Invalid Email or password.'
  end

  scenario 'and then Logs out' do
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    find_button('Log in').trigger(:click)

    find_link(@user.email).trigger(:click)
    find_button('Log out').trigger(:click)

    expect(page).not_to have_content @user.email
    expect(page).not_to have_text @user.name
    expect(page).to have_text 'Welcome Icalier!'
  end
end
