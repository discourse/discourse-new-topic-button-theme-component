import Component from "@glimmer/component";
import { getOwner } from "@ember/application";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DButtonTooltip from "discourse/components/d-button-tooltip";
import routeAction from "discourse/helpers/route-action";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";
import DTooltip from "float-kit/components/d-tooltip";

export default class CustomHeaderTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service siteSettings;

  canCreateTopic = this.currentUser?.can_create_topic;

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

  get composerCategory() {
    if (settings.open_composer_without_category) {
      return null;
    } else {
      return this.currentCategory;
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
        !this.canCreateTopicWithTag
      );
    }
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

  get showDisabledTooltip() {
    return this.createTopicDisabled && !this.currentCategory?.read_only_banner;
  }

  @action
  createTopic() {
    this.composer.openNewTopic({
      preferDraft: true,
      category: this.composerCategory,
      tags: this.currentTag,
    });
  }

  <template>
    {{#if this.currentUser}}
      <DButtonTooltip>
        <:button>
          <DButton
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
          {{#if this.showDisabledTooltip}}
            <DTooltip
              @icon="circle-info"
              @content={{i18n (themePrefix "button_disabled_tooltip")}}
            />
          {{/if}}
        </:tooltip>
      </DButtonTooltip>
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
