import Component from "@glimmer/component";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

export default class CustomHeaderTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;

  topic = this.router.currentRouteName.includes("topic")
    ? getOwner(this).lookup("controller:topic")
    : null;

  get userHasDraft() {
    return this.currentUser?.get("has_topic_draft");
  }

  get currentTag() {
    if (this.router.currentRoute.attributes?.tag?.id) {
      return [
        this.router.currentRoute.attributes?.tag?.id,
        ...(this.router.currentRoute.attributes?.additionalTags ?? []),
      ]
        .filter(Boolean)
        .filter((t) => !["none", "all"].includes(t))
        .join(",");
    } else {
      return this.topic?.model?.tags?.join(",");
    }
  }

  get currentCategory() {
    return (
      this.router.currentRoute.attributes?.category ||
      (this.topic?.model?.category_id
        ? Category.findById(this.topic?.model?.category_id)
        : null)
    );
  }

  get createTopicLabel() {
    return this.userHasDraft
      ? i18n("topic.open_draft")
      : settings.new_topic_button_text;
  }

  get createTopicTitle() {
    if (!this.userHasDraft && settings.new_topic_button_title.length) {
      return settings.new_topic_button_title;
    } else {
      return this.createTopicLabel;
    }
  }

  @action
  createTopic() {
    this.composer.openNewTopic({
      preferDraft: true,
      category: this.currentCategory,
      tags: this.currentTag,
    });
  }

  <template>
    {{#if this.currentUser}}
      <DButton
        @action={{this.createTopic}}
        @translatedLabel={{this.createTopicLabel}}
        @translatedTitle={{this.createTopicTitle}}
        @icon={{settings.new_topic_button_icon}}
        id="new-create-topic"
        class="btn-default header-create-topic"
      />
    {{else if settings.show_to_anon}}
      <DButton
        @action={{routeAction "showLogin"}}
        @translatedLabel={{this.createTopicLabel}}
        @translatedTitle={{this.createTopicTitle}}
        @icon={{settings.new_topic_button_icon}}
        id="new-create-topic"
        class="btn-default header-create-topic"
      />
    {{/if}}
  </template>
}
