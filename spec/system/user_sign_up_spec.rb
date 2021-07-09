# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User sign up', type: :system do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  before do
    visit new_user_registration_path
  end

  scenario 'with valid data' do
    fill_in 'user_name', with: name
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    click_button 'Sign up'

    expect(page).to have_content('Here are your current arrows')
    expect(page).to have_text email
  end

  scenario 'invalid when email already exists' do
    user = create :user

    fill_in 'user_name', with: user.name
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: password
    click_button 'Sign up'

    expect(page).to have_no_text user.email
    expect(page).to have_text 'Email has already been taken'
  end

  scenario 'invalid with password confirmation mismatch' do
    user = create :user

    fill_in 'user_name', with: name
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: user.password
    click_button 'Sign up'

    expect(page).to have_no_text email
    expect(page).to have_text 'Password confirmation doesn\'t match Password'
  end
end
