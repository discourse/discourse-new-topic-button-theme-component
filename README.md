# Discourse New Topic button theme component

A simple theme to add a "New Topic" button on every page.

## Button text

The button label comes from one of two sources:

- **Theme setting (default)** — the `new_topic_button_text` setting is used verbatim, so the
  label reads the same in every language.
- **Core translation** — enable `use_core_button_text` to use core's own `topic.create`
  string, which is translated into each visitor's language. `new_topic_button_text` is
  ignored in this mode.

`new_topic_button_title` controls the tooltip in both modes.

More information: https://meta.discourse.org/t/new-topic-button-on-all-pages-theme-component/84551
