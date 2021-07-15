require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it {
      should have_many(:authored_arrows)
        .class_name('Arrow')
        .dependent(:destroy)
    }
    it {
      should have_many(:owned_arrows)
        .class_name('Arrow')
        .dependent(:destroy)
    }
  end

  describe '#to_select' do
    context 'when there are three users' do
      it 'should return two users' do
        user_1 = create :user
        user_2 = create :user

        subject.save

        expect(User.to_select(subject).count).to eql 2
      end

      it 'should not return subject\'s id' do
        user_1 = create :user
        user_2 = create :user

        subject.save

        dropdown_users = User.to_select(subject)

        dropdown_users.each do |user|
          expect(user.name).not_to eq subject.name
        end
      end
    end
  end
end
