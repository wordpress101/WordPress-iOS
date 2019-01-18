import {warn, fail, danger} from "danger"

if (danger.github == null || danger.github.pr == null) {
    fail("Not running on a Github PR.");
    return;
}

const githubLabels = containsDoNotMerge = false;
// A PR should have at least one label
if (githubLabels.count == 0) { // if github.pr_labels.empty?
    warn("PR is missing at least one label.");
}

// A PR shouldn't be merged with the 'DO NOT MERGE' label
let containsDoNotMerge = false;
githubLabels.forEach(label => {
    if (label.name.includes("DO NOT MERGE")) {
        containsDoNotMerge = true;
        break;
    }
});
if (containsDoNotMerge) { // if github.pr_labels.include? "[Status] DO NOT MERGE"
    warn("This PR is tagged with 'DO NOT MERGE'.");
}

// Warn when there is a big PR
if (danger.github.pr.additions + danger.github.pr.deletions > 0) {
    warn("PR has more than 500 lines of code changing. Consider splitting into smaller PRs if possible.");
}

const has_milestone = danger.github.api.pr_json["milestone"] != null;
if (!has_milestone) {
    warn("PR is not assigned to a milestone.");
}

// Core Data Model Safety Checks
const target_release_branch = danger.github.pr.base.ref.startsWith("release");
const has_modified_model = danger.git.modified_files.include? ... // git.modified_files.include? "WordPress/Classes/WordPress.xcdatamodeld/*/contents"
if (target_release_branch && has_modified_model) {
    warn("Core Data: Do not edit an existing model in a release branch unless it hasn't been released to testers yet. Instead create a new model version and merge back to develop soon.")
}

// # Podfile: no references to commit hashes
// warn("Podfile: reference to a commit hash") if `grep -e "^[^#]*:commit" Podfile`.length > 1