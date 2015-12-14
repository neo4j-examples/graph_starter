require './spec/rails_helper'

describe 'Asset slugs' do
  class Foo < GraphStarter::Asset
    property :title

    name_property :title
  end

  before { clear_db }

  describe '.unique_slug_from' do
    subject { GraphStarter::Asset.unique_slug_from(string) }

    context 'Without assets with slugs' do
      let_context string: 'Test title' do
        it { should eq 'test-title' }
      end

      let_context string: 'Gölcük, Turkey Number 2!' do
        it { should eq 'golcuk-turkey-number-2' }
      end
    end

    context 'With existing asset slug' do
      before { Foo.create(title: 'Gölcük, Turkey', slug: 'golcuk-turkey') }

      let_context string: 'Gölcük, Turkey!' do
        it { should eq 'golcuk-turkey-2' }
      end

      context 'With another existing asset slug' do
        before { Foo.create(title: 'Gölcük, Turkey!', slug: 'golcuk-turkey-2') }

        let_context string: 'Gölcük, Turkey!!' do
          it { should eq 'golcuk-turkey-3' }
        end
      end
    end

  end
end

