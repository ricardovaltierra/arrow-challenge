# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User edit account', type: :system do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  before do
    @user = create :user
    visit new_user_session_path
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Log in'
    visit edit_user_registration_path
  end

  scenario 'with a new name' do
    fill_in 'user_name', with: name
    fill_in 'user_current_password', with: @user.password
    click_button 'Update'

    expect(page).to have_text 'Your account has been updated successfully.'
    expect(page).to have_text name
  end

  scenario 'with a new email' do
    fill_in 'user_email', with: email
    fill_in 'user_current_password', with: @user.password
    click_button 'Update'

    expect(page).to have_text 'Your account has been updated successfully.'
    expect(page).to have_text email
  end

  scenario 'with a new password' do
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    fill_in 'user_current_password', with: @user.password
    click_button 'Update'

    expect(page).to have_text 'Your account has been updated successfully.'
  end

  scenario 'with a new name, email and password' do
    fill_in 'user_name', with: name
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    fill_in 'user_current_password', with: @user.password
    click_button 'Update'

    expect(page).to have_text 'Your account has been updated successfully.'
    expect(page).to have_text name
    expect(page).to have_text email
  end

  scenario 'with new password mismatch' do
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: 'MyWrongPassword'
    fill_in 'user_current_password', with: @user.password
    click_button 'Update'

    expect(page).to have_text "Password confirmation doesn't match Password"
  end

  scenario 'without current password to confirm' do
    fill_in 'user_name', with: name
    click_button 'Update'

    expect(page).to have_text "Current password can't be blank"
  end
end
