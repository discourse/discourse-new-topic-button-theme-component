import { getOwner } from "@ember/owner";
import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import discoveryFixture from "discourse/tests/fixtures/discovery-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Custom Header Topic Button | tag route", function (needs) {
  needs.settings({ tagging_enabled: true });

  needs.pretender((server, helper) => {
    server.get("/tag/important/l/latest.json", () => {
      return helper.response(
        cloneJSON(discoveryFixture["/tag/important/l/latest.json"])
      );
    });

    server.get("/tag/:tag_name/notifications", () => {
      return helper.response({
        tag_notification: {
          id: "important",
          notification_level: 1,
        },
      });
    });
  });

  test("tag route provides tag name in route attributes", async function (assert) {
    await visit("/tag/important");

    const router = getOwner(this).lookup("service:router");
    const tagName = router.currentRoute.attributes?.tag?.name;

    assert.strictEqual(
      tagName,
      "important",
      "tag.name is available for composer pre-fill"
    );
  });
});
