require './spec/rails_helper'

describe 'Asset authorization' do
  before { clear_db }

  let(:current_user) { nil }
  let(:asset_attributes) { {} }
  let(:asset) { Person.create(asset_attributes) }

  subject { Person.authorized_for(current_user) }

  it { should include(asset) }

  context 'private asset' do
    let(:asset_attributes) { {private: true} }
    it { should_not include(asset) }

    context 'user is logged in' do
      let(:current_user_attributes) { {} }
      let(:current_user) { User.create(current_user_attributes) }

      it { should_not include(asset) }

      context 'current_user is admin' do
        let(:current_user_attributes) { {admin: true} }
        it { should include(asset) }
      end

      context 'user has access to asset' do
        before { asset.allowed_users = current_user }
        it { should include(asset) }
      end

      context 'user has access to one of the asset categories' do
        let(:category) { Company.create(name: 'Acme Inc. Co.') }

        before do
          asset.employer = category
          category.allowed_users = current_user
        end

        it { should include(asset) }
      end
    end
  end
end
