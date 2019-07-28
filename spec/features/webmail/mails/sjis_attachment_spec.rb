require 'spec_helper'

describe "webmail_mails", type: :feature, dbscope: :example, imap: true, js: true, tmpdir: true do
  context "when mail is sent with sjis text file" do
    let(:user) { webmail_imap }
    let(:item_subject) { "subject-#{unique_id}" }
    let(:item_texts) { Array.new(rand(1..10)) { "message-#{unique_id}" } }
    let(:content) { Rails.root.join("spec/fixtures/webmail/sjis.bin") }
    let!(:file) do
      tmp_ss_file(contents: content, user: user, content_type: "text/plain")
    end

    shared_examples "webmail/mails send with sjis text attachment flow" do
      before do
        ActionMailer::Base.deliveries.clear
        login_user(user)

        file.name = "テストあいう.txt"
        file.filename = "テストあいう.txt"
        file.save!
      end

      after do
        ActionMailer::Base.deliveries.clear
      end

      it do
        # send
        visit index_path
        click_link I18n.t('ss.links.new')
        within "form#item-form" do
          fill_in "to", with: user.email + "\n"
          fill_in "item[subject]", with: item_subject
          fill_in "item[text]", with: item_texts.join("\n")

          click_on I18n.t("ss.links.upload")
        end
        wait_for_cbox do
          expect(page).to have_content(file.name)
          first(".file-view a").click
        end
        within "form#item-form" do
          click_on I18n.t('ss.buttons.send')
        end

        expect(ActionMailer::Base.deliveries).to have(1).items
        ActionMailer::Base.deliveries.first.tap do |mail|
          expect(mail.from.first).to eq address
          expect(mail.to.first).to eq user.email
          expect(mail.subject).to eq item_subject
          expect(mail.multipart?).to be_truthy
          expect(mail.parts.length).to eq 2
          expect(mail.parts[0].body.raw_source).to include(item_texts.join("\r\n"))
          expect(mail.parts[1].content_type).to include("text/plain")
          expect(mail.parts[1].content_type).to include("Shift_JIS")
          expect(mail.parts[1].body.raw_source).to eq Base64.encode64(File.binread(content))
        end
      end
    end

    shared_examples "webmail/mails account and group flow" do
      before do
        @save = SS.config.webmail.store_mails
        SS.config.replace_value_at(:webmail, :store_mails, store_mails)
      end

      after do
        SS.config.replace_value_at(:webmail, :store_mails, @save)
      end

      describe "webmail_mode is account" do
        let(:index_path) { webmail_mails_path(account: 0) }
        let(:address) { user.email }

        it_behaves_like "webmail/mails send with sjis text attachment flow"
      end

      describe "webmail_mode is group" do
        let(:group) { create :webmail_group }
        let(:index_path) { webmail_mails_path(account: group.id, webmail_mode: :group) }
        let(:address) { group.contact_email }

        before { user.add_to_set(group_ids: [ group.id ]) }

        it_behaves_like "webmail/mails send with sjis text attachment flow"
      end
    end

    context "when store_mails is false" do
      let(:store_mails) { false }

      it_behaves_like "webmail/mails account and group flow"
    end

    context "when store_mails is true" do
      let(:store_mails) { true }

      it_behaves_like "webmail/mails account and group flow"
    end
  end
end
