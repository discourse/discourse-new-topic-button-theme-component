import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import I18n from "discourse-i18n";

export default class CustomHeaderTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service siteSettings;

  @tracked currentRouteAttributes = this.router.currentRoute.attributes;
  @tracked userHasDraft = this.currentUser.has_topic_draft;

  get currentTag() {
    return [
      this.currentRouteAttributes?.tag?.id,
      ...(this.currentRouteAttributes?.additionalTags ?? []),
    ]
      .filter(Boolean)
      .filter((t) => !["none", "all"].includes(t))
      .join(",");
  }

  get canCreateTopic() {
    return this.currentUser.can_create_topic;
  }

  get canCreateTopicWithTag() {
    return (
      !this.currentRouteAttributes?.tag ||
      !this.currentRouteAttributes?.tag?.staff ||
      this.currentUser.staff
    );
  }

  get canCreateTopicWithCategory() {
    return (
      !this.currentRouteAttributes?.category ||
      this.currentRouteAttributes?.category?.permission
    );
  }

  get createTopicDisabled() {
    if (this.userHasDraft) {
      return false;
    } else {
      return (
        !this.canCreateTopicWithCategory ||
        !this.canCreateTopicWithTag ||
        !this.currentUser.can_create_topic ||
        this.currentRouteAttributes?.category?.read_only_banner
      );
    }
  }

  get createTopicLabel() {
    return this.userHasDraft
      ? I18n.t("topic.open_draft")
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
  updateRouteAttributes() {
    return (this.currentRouteAttributes = this.router.currentRoute.attributes);
  }

  @action
  updateDraftStatus() {
    return (this.userHasDraft = this.currentUser.has_topic_draft);
  }

  @action
  createTopic() {
    this.composer.openNewTopic({
      preferDraft: true,
      category: this.currentRouteAttributes?.category,
      tags: this.currentTag,
    });
  }

  <template>
    {{#if this.currentUser}}
      <DButton
        {{didUpdate
          this.updateRouteAttributes
          this.router.currentRoute.attributes
        }}
        {{didUpdate this.updateDraftStatus this.router.currentRoute.attributes}}
        @action={{this.createTopic}}
        @translatedLabel={{this.createTopicLabel}}
        @translatedTitle={{this.createTopicTitle}}
        @icon={{settings.new_topic_button_icon}}
        @id="new-create-topic"
        @class="btn-default header-create-topic"
        @disabled={{this.createTopicDisabled}}
      />
    {{/if}}
  </template>
}
