# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArrowsController, type: :request do

  describe '#show' do
    
    context 'with no user logged in' do
      before(:example) { get arrow_path(1) }
      it 'should redirect to login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#new' do
    context 'with no user logged in' do
        before(:example) { get new_arrow_path }
      it 'should redirect to login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
