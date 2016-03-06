require './spec/rails_helper'

describe 'Asset authorization' do
  before { clear_db }

  let(:current_user) { nil }
  let(:asset_attributes) { {} }
  let!(:asset) { create(:person, asset_attributes) }

  let(:category_attributes) { {} }
  let!(:category) { create(:company, category_attributes) }

  subject { Person.authorized_for(current_user).to_a }

  it { should include(asset) }

  let_context(asset_attributes: {private: true}) do
    it { should_not include(asset) }

    context 'user is logged in' do
      let(:current_user_attributes) { {} }
      let(:current_user) { User.create(current_user_attributes) }

      it { should_not include(asset) }

      context 'current_user is the asset creator' do
        before { asset.creators << current_user }

        it { should include(asset) }
      end

      context 'current_user is admin' do
        let(:current_user_attributes) { {admin: true} }

        it { should include(asset) }
      end

      context 'user has access to asset' do
        before { asset.allowed_users = current_user }
        it { should include(asset) }
      end

      context 'asset has the category' do
        before { asset.employer = category }

        it { should_not include(asset) }

        context 'current_user is admin' do
          let(:current_user_attributes) { {admin: true} }

          it { should include(asset) }
        end

        context 'current_user is the category creator' do
          before { category.creators << current_user }

          it { should_not include(asset) }
        end

        context 'current_user has access to the category' do
          before { category.allowed_users = current_user }

          it { should include(asset) }
        end
      end
    end
  end

  let_context(asset_attributes: {private: nil}) do
    it { should include(asset) }

    context 'user is logged in' do
      let(:current_user_attributes) { {} }
      let(:current_user) { User.create(current_user_attributes) }

      it { should include(asset) }

      context 'current_user is the asset creator' do
        before { asset.creators << current_user }

        it { should include(asset) }
      end

      context 'current_user is admin' do
        let(:current_user_attributes) { {admin: true} }

        it { should include(asset) }
      end

      context 'user has access to asset' do
        before { asset.allowed_users = current_user }
        it { should include(asset) }
      end

      context 'asset has the category' do
        before { asset.employer = category }

        it { should include(asset) }

        context 'current_user is admin' do
          let(:current_user_attributes) { {admin: true} }

          it { should include(asset) }
        end

        context 'current_user is the category creator' do
          before { category.creators << current_user }

          it { should include(asset) }
        end

        context 'current_user has access to the category' do
          before { category.allowed_users = current_user }

          it { should include(asset) }
        end
      end
    end
  end

  let_context(asset_attributes: {private: false}) do
    it { should include(asset) }

    context 'user is logged in' do
      let(:current_user_attributes) { {} }
      let(:current_user) { User.create(current_user_attributes) }

      it { should include(asset) }

      context 'current_user is the asset creator' do
        before { asset.creators << current_user }

        it { should include(asset) }
      end

      context 'current_user is admin' do
        let(:current_user_attributes) { {admin: true} }

        it { should include(asset) }
      end

      context 'user has access to asset' do
        before { asset.allowed_users = current_user }
        it { should include(asset) }
      end

      context 'asset has the category' do
        before { asset.employer = category }

        it { should include(asset) }

        context 'current_user is admin' do
          let(:current_user_attributes) { {admin: true} }

          it { should include(asset) }
        end

        context 'current_user is the category creator' do
          before { category.creators << current_user }

          it { should include(asset) }
        end

        context 'current_user has access to the category' do
          before { category.allowed_users = current_user }

          it { should include(asset) }
        end
      end
    end
  end

end
