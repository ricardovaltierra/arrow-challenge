# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe '#index' do
    context 'with user logged in' do
      login_user

      it 'should have a current user' do
        expect(subject.current_user).to be_instance_of(User)
      end

      it 'should get index' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when no user is logged in' do
      it 'should redirect to login page' do
        get :index
        expect(response).to redirect_to('/users/sign_in')
      end
    end
  end
end
