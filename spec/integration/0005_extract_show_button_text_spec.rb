# frozen_string_literal: true

RSpec.describe "0005-extract-show-button-text migration" do
  let!(:theme) { upload_theme_component }

  def migrate_with_text(text)
    theme.update_setting(:new_topic_button_text, text)
    theme.save!
    run_theme_migration(theme, "0005-extract-show-button-text")
  end

  it "hides the label for sites that emptied the text to get an icon-only button" do
    migrate_with_text("")

    expect(theme.settings[:show_button_text].value).to eq(false)
    expect(theme.settings[:new_topic_button_text].value).to eq("")
  end

  it "moves sites still on the old default over to core's translated text" do
    migrate_with_text("New Topic")

    expect(theme.settings[:show_button_text].value).to eq(true)
    expect(theme.settings[:new_topic_button_text].value).to eq("")
  end

  it "keeps custom text" do
    migrate_with_text("Ask a question")

    expect(theme.settings[:show_button_text].value).to eq(true)
    expect(theme.settings[:new_topic_button_text].value).to eq("Ask a question")
  end

  it "leaves sites that never changed the text on the new defaults" do
    run_theme_migration(theme, "0005-extract-show-button-text")

    expect(theme.settings[:show_button_text].value).to eq(true)
    expect(theme.settings[:new_topic_button_text].value).to eq("")
  end
end
