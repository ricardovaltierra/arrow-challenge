require 'rails_helper'

RSpec.describe Arrow, type: :model do
  let(:description) { Faker::Lorem.paragraph }
  let(:author) { create :user }
  let(:owner) { create :user }
  subject { build(:arrow, author_id: author.id, owner_id: owner.id) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { should validate_presence_of :description }
    it {
      should validate_length_of(:description)
        .is_at_least(30)
        .is_at_most(280)
    }
    it { should_not allow_value('').for(:description) }
    it {
      should_not allow_value('12345678901234567890123456789')
        .for(:description)
    }
    it {
      should allow_value('This is a bit longer than 30 chars')
        .for(:description)
    }
  end

  describe 'associations' do
    it {
      should belong_to(:author)
        .class_name('User')
    }
    it {
      should belong_to(:owner)
        .class_name('User')
    }
  end

  describe '#arrows_with_author' do
    context 'when there are 3 received arrows' do
      it 'should return as first the last arrow received' do
        arrow_1 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)
        arrow_2 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)
        arrow_3 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)

        expect(Arrow.arrows_with_author(owner).first.id).to eq arrow_3.id
      end

      it 'should return the same author for each arrow' do 
        arrow_1 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)
        arrow_2 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)
        arrow_3 = create(:arrow,
          description: description,
          author_id: author.id,
          owner_id: owner.id)
          
        expect(arrow_1.author).to eq author
        expect(arrow_2.author).to eq author
        expect(arrow_3.author).to eq author
      end
    end
  end
end
