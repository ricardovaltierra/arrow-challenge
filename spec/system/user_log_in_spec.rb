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
    click_button 'Log in'

    expect(page).to have_text 'Signed in successfully.'
    expect(page).to have_link 'Log out'
    expect(page).to have_current_path root_path
  end

  scenario 'invalid with unregistered account' do
    fill_in 'user_email', with: Faker::Internet.email
    fill_in 'user_password', with: 'A123pass'
    click_button 'Log in'

    expect(page).to have_no_text 'Signed in successfully.'
    expect(page).to have_text 'Invalid Email or password.'
    expect(page).to have_no_link 'Log out'
  end

  scenario 'invalid with invalid password' do
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: 'FakePassword'
    click_button 'Log in'

    expect(page).to have_no_text 'Signed in successfully.'
    expect(page).to have_text 'Remember me'
    expect(page).to have_link 'Forgot your password?'
  end
end
