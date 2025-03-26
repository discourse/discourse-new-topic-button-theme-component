# frozen_string_literal: true

RSpec.describe "New topic header button", type: :system do
  fab!(:theme) { upload_theme_component }

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
      visit("/c/#{category2.id}")

      find("#new-create-topic").click
      expect(page).to have_css(".category-input [data-category-id='#{category2.id}']")
    end

    it "should not contain text when new_topic_button_text is empty" do
      theme.update_setting(:new_topic_button_text, "")
      theme.save!

      visit("/")
      expect(page).not_to have_css("#new-create-topic .d-button-label")
    end

    it "should update icon based on new_topic_button_icon setting" do
      theme.update_setting(:new_topic_button_icon, "xmark")
      theme.save!

      visit("/")
      expect(page).to have_css("#new-create-topic .d-icon-xmark")
    end

    it "should not display the default new topic button when hide_default_button is enabled" do
      theme.update_setting(:hide_default_button, true)
      theme.save!

      visit("/")
      expect(page).not_to have_css("#create-topic")
    end

    it "does not open composer if user can't post in the category" do
      category.set_permissions(everyone: :readonly)
      category.save!
      visit("/c/#{category.id}")

      find("#new-create-topic").click

      expect(page).not_to have_css(".composer-open")
    end
  end

  context "with anonymous visitor" do
    it "when show_to_anon is disabled, it should not display a new topic button in the header" do
      theme.update_setting(:show_to_anon, false)
      theme.save!

      visit("/")

      expect(page).not_to have_css("#new-create-topic")
    end

    it "when show_to_anon is enabled, it should display a new topic button in the header" do
      theme.update_setting(:show_to_anon, true)
      theme.save!

      visit("/")

      expect(page).to have_css("#new-create-topic")
    end

    it "when show_to_anon is enabled, clicking the new topic button redirects to login" do
      theme.update_setting(:show_to_anon, true)
      theme.save!

      visit("/")

      find("#new-create-topic").click

      expect(page).to have_css(".login-fullpage")
    end
  end
end
