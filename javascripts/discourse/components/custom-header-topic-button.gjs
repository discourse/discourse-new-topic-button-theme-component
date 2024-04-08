import Component from "@glimmer/component";
import { action } from "@ember/object";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DButtonTooltip from "discourse/components/d-button-tooltip";
import i18n from "discourse-common/helpers/i18n";
import I18n from "discourse-i18n";
import DTooltip from "float-kit/components/d-tooltip";

export default class CustomHeaderTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service siteSettings;

  canCreateTopic = this.currentUser?.can_create_topic;

  get userHasDraft() {
    return this.currentUser?.get("has_topic_draft");
  }

  get currentTag() {
    return [
      this.router.currentRoute.attributes?.tag?.id,
      ...(this.router.currentRoute.attributes?.additionalTags ?? []),
    ]
      .filter(Boolean)
      .filter((t) => !["none", "all"].includes(t))
      .join(",");
  }

  get currentCategory() {
    return this.router.currentRoute.attributes?.category;
  }

  get canCreateTopicWithTag() {
    return (
      !this.router.currentRoute.attributes?.tag?.staff ||
      this.currentUser?.staff
    );
  }

  get canCreateTopicWithCategory() {
    return !this.currentCategory || this.currentCategory?.permission;
  }

  get createTopicDisabled() {
    if (this.userHasDraft) {
      return false;
    } else {
      return (
        !this.canCreateTopic ||
        !this.canCreateTopicWithCategory ||
        !this.canCreateTopicWithTag ||
        this.currentCategory?.read_only_banner
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
  createTopic() {
    this.composer.openNewTopic({
      preferDraft: true,
      category: this.currentCategory,
      tags: this.currentTag,
    });
  }

  <template>
    {{#if this.currentUser}}
      <DButtonTooltip>
        <:button>
          <DButton
            {{didUpdate
              this.updateDraftStatus
              this.router.currentRoute.attributes
            }}
            @action={{this.createTopic}}
            @translatedLabel={{this.createTopicLabel}}
            @translatedTitle={{this.createTopicTitle}}
            @icon={{settings.new_topic_button_icon}}
            id="new-create-topic"
            class="btn-default header-create-topic"
            disabled={{this.createTopicDisabled}}
          />
        </:button>
        <:tooltip>
          {{#if this.createTopicDisabled}}
            <DTooltip
              @icon="info-circle"
              @content={{i18n (themePrefix "button_disabled_tooltip")}}
            />
          {{/if}}
        </:tooltip>
      </DButtonTooltip>
    {{/if}}
  </template>
}
