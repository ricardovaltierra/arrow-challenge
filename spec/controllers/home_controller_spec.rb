require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  login_user

  it 'should have a current user' do
    expect(subject.current_user).to_not eq(nil)
  end

  it 'should get index' do
    get :index
    expect(response).to be_successful
  end

  it 'should get dashboard' do
    get :dashboard
    expect(response).to be_successful
  end
end
