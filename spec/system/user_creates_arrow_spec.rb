# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User creates arrow', type: :system do 
  let(:description) { Faker::Lorem.paragraph }

  before do
    @user_1 = create :user
    @user_2 = create :user
    visit new_user_session_path
    fill_in 'user_email', with: @user_1.email
    fill_in 'user_password', with: @user_1.password
    click_button 'Log in'
    visit new_arrow_path
  end
  
  scenario 'with the required fields properly set' do
    fill_in 'arrow_description', with: description
    find('#arrow_owner_id option').find(@user_2.name).select_option
    click_button 'send'.upcase
  end
end
