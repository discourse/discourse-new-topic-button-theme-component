export default function migrate(settings) {
  const settingsToMigrate = [
    "New_topic_button_icon",
    "New_topic_button_text",
    "New_topic_button_title",
    "Hide_default_button",
  ];

  settingsToMigrate.forEach((oldKey) => {
    const newKey = oldKey.toLowerCase();
    if (settings.has(oldKey)) {
      settings.set(newKey, settings.get(oldKey));
      settings.delete(oldKey);
    }
  });

  return settings;
}
