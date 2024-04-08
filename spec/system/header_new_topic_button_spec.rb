# frozen_string_literal: true

RSpec.describe "New topic header button", type: :system do
  fab!(:theme) { upload_theme_component }

  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[1]) }
  fab!(:category) { Fabricate(:category, read_only_banner: true) }
  fab!(:category2) { Fabricate(:category) }

  context "logged in user" do
    before { sign_in(user) }

    it "should display a new topic button in the header" do
      visit("/")

      expect(page).to have_css("#new-create-topic")
    end

    it "should open the composer to the correct category when the header button is clicked" do
      visit("/c/#{category2.id}")

      find("#new-create-topic").click
      expect(page).to have_css(
        ".category-input [data-category-id='#{category2.id}']"
      )
    end

    it "should not contain text when new_topic_button_text is empty" do
      theme.update_setting(:new_topic_button_text, "")
      theme.save!

      visit("/")
      expect(page).not_to have_css("#new-create-topic .d-button-label")
    end

    it "should update icon based on new_topic_button_icon setting" do
      theme.update_setting(:new_topic_button_icon, "times")
      theme.save!

      visit("/")
      expect(page).to have_css("#new-create-topic .d-icon-times")
    end

    it "should not display the default new topic button when hide_default_button is enabled" do
      theme.update_setting(:hide_default_button, true)
      theme.save!

      visit("/")
      expect(page).not_to have_css("#create-topic")
    end

    it "does not open composer if user can't post in the category" do
      visit("/c/#{category.id}")

      find("#new-create-topic").click
      expect(page).not_to have_css(".composer-open")
    end
  end

  context "anonymous visitor" do
    it "should not display a new topic button in the header for anons" do
      visit("/")

      expect(page).not_to have_css("#new-create-topic")
    end
  end
end
