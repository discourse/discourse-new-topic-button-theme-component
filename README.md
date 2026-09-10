# Discourse New Topic button theme component

A simple theme to add a "New Topic" button on every page.

## Button text

- `show_button_text` — show a text label next to the icon. Disable it for an icon-only button.
- `new_topic_button_text` — custom label. Leave it empty (the default) to use core's own
  `topic.create` string, which is translated into each visitor's language.
- `new_topic_button_title` — tooltip; falls back to the label when empty.

Sites upgrading from before `show_button_text` existed are migrated automatically: an empty
label becomes `show_button_text: false`, and the old default "New Topic" becomes empty so those
sites pick up core's translations.

More information: https://meta.discourse.org/t/new-topic-button-on-all-pages-theme-component/84551
