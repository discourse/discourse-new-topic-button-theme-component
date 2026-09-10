const OLD_DEFAULT = "New Topic";

export default function migrate(settings) {
  const text = settings.get("new_topic_button_text");

  if (text === undefined) {
    return settings;
  }

  settings.set("show_button_text", text.length > 0);
  settings.set(
    "new_topic_button_text",
    text.trim() === OLD_DEFAULT ? "" : text
  );

  return settings;
}
