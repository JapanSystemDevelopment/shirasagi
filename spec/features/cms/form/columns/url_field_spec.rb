require 'spec_helper'

describe Cms::Form::ColumnsController, type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:form) { create(:cms_form, cur_site: site, sub_type: 'static') }
  let(:name) { unique_id }

  before { login_cms_user }

  context 'with empty html_tag' do
    it do
      #
      # Create
      #
      visit cms_form_path(site, form)
      click_on I18n.t('cms.buttons.manage_columns')
      wait_for_event_fired("ss:dropdownOpened") { click_on I18n.t('ss.links.new') }
      within ".cms-dropdown-menu" do
        click_on I18n.t('cms.columns.cms/url_field')
      end

      within 'form#item-form' do
        fill_in 'item[name]', with: name
        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 1
      Cms::Column::Base.site(site).where(form_id: form.id).first.tap do |item|
        expect(item.name).to eq name
        expect(item.required).to eq 'required'
        expect(item.html_tag).to be_nil
      end

      #
      # Read & Update
      #
      visit cms_form_columns_path(site, form)
      click_on name
      click_on I18n.t('ss.links.edit')
      within 'form#item-form' do
        select I18n.t('ss.options.state.optional'), from: 'item[required]'
        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 1
      Cms::Column::Base.site(site).where(form_id: form.id).first.tap do |item|
        expect(item.name).to eq name
        expect(item.required).to eq 'optional'
        expect(item.html_tag).to be_nil
      end

      #
      # Delete
      #
      visit cms_form_columns_path(site, form)
      click_on name
      click_on I18n.t('ss.links.delete')
      within 'form' do
        click_on I18n.t('ss.buttons.delete')
      end
      wait_for_notice I18n.t('ss.notice.deleted')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 0
    end
  end

  context 'with a html_tag' do
    it do
      #
      # Create
      #
      visit cms_form_path(site, form)
      click_on I18n.t('cms.buttons.manage_columns')
      wait_for_event_fired("ss:dropdownOpened") { click_on I18n.t('ss.links.new') }
      within ".cms-dropdown-menu" do
        click_on I18n.t('cms.columns.cms/url_field')
      end

      within 'form#item-form' do
        fill_in 'item[name]', with: name
        select 'a', from: 'item[html_tag]'
        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 1
      Cms::Column::Base.site(site).where(form_id: form.id).first.tap do |item|
        expect(item.name).to eq name
        expect(item.required).to eq 'required'
        expect(item.html_tag).to eq 'a'
      end

      #
      # Read & Update
      #
      visit cms_form_columns_path(site, form)
      click_on name
      click_on I18n.t('ss.links.edit')
      within 'form#item-form' do
        select I18n.t('ss.options.state.optional'), from: 'item[required]'
        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 1
      Cms::Column::Base.site(site).where(form_id: form.id).first.tap do |item|
        expect(item.name).to eq name
        expect(item.required).to eq 'optional'
        expect(item.html_tag).to eq 'a'
      end

      #
      # Delete
      #
      visit cms_form_columns_path(site, form)
      click_on name
      click_on I18n.t('ss.links.delete')
      within 'form' do
        click_on I18n.t('ss.buttons.delete')
      end
      wait_for_notice I18n.t('ss.notice.deleted')
      expect(Cms::Column::Base.site(site).where(form_id: form.id).count).to eq 0
    end
  end
end
