# frozen_string_literal: true

RSpec.describe "New topic header button", type: :system do
  let!(:theme) { upload_theme_component }

  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[1]) }
  fab!(:category)
  fab!(:category2) { Fabricate(:category) }

  context "with logged in user" do
    before { sign_in(user) }

    it "should display a new topic button in the header" do
      visit("/")

      expect(page).to have_css("#new-create-topic")
    end

    it "should open the composer to the correct category when the header button is clicked" do
      visit("/c/#{category2.slug}/#{category2.id}")
      find("#new-create-topic").click

      expect(page).to have_css(".category-input [data-category-id='#{category2.id}']")
    end

    context "when new_topic_button_text is empty" do
      before do
        theme.update_setting(:new_topic_button_text, "")
        theme.save!
      end

      it "doesn’t show the label" do
        visit("/")

        expect(page).to have_no_css("#new-create-topic .d-button-label")
      end
    end

    context "when new_topic_button_icon is set" do
      before do
        theme.update_setting(:new_topic_button_icon, "xmark")
        theme.save!
      end

      it "uses the correct icon" do
        visit("/")

        expect(page).to have_css("#new-create-topic .d-icon-xmark")
      end
    end

    context "when hide_default_button is enabled" do
      before do
        theme.update_setting(:hide_default_button, true)
        theme.save!
      end

      it "should not display the default new topic button" do
        visit("/")

        expect(page).to have_no_css("#create-topic")
      end
    end

    context "when category is inaccessible" do
      before do
        category.set_permissions(everyone: :readonly)
        category.save!
      end

      it "can open composer" do
        visit("/c/#{category.slug}/#{category.id}")

        expect(page).to have_css("#new-create-topic:not([disabled])")
      end
    end
  end

  context "with anonymous visitor" do
    context "when show_to_anon is disabled" do
      before do
        theme.update_setting(:show_to_anon, false)
        theme.save!
      end

      it "displays no new topic button in the header" do
        visit("/")

        expect(page).to have_no_css("#new-create-topic")
      end
    end

    context "when show_to_anon is enabled" do
      before do
        theme.update_setting(:show_to_anon, true)
        theme.save!
      end

      it "redirects to login when click new topic button" do
        visit("/")
        find("#new-create-topic").click

        expect(page).to have_css(".login-fullpage")
      end
    end
  end
end
