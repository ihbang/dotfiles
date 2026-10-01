# A2SYS issue tracking: the Milestone/Epic tree and the Serving Board

Set by the user on 2026-09-28; not in the Confluence pages. Covers serving-team work in every
a2sys-platform repository. Reached from `~/.claude/references/a2sys-dev-rules.md`, and injected
whole by a PreToolUse hook (`~/.claude/hooks/a2sys-issue-context.sh`) on every issue create.

## The tree

- **Milestone** and **Epic** are issues in `a2sys-platform/serving-team` carrying the org issue
  types `Milestone` / `Epic`. GitHub's own milestone feature stays unused.
- Work issues live in the code repository, typed `Feature` / `Bug` / `Task` (`feat` → Feature,
  `fix` → Bug, `refactor` / `chore` / `docs` / `test` → Task).
- Milestone → Epic → work issue, joined by sub-issues (cross-repo works). Each work issue has
  exactly one parent Epic, each Epic exactly one parent Milestone.
- Bodies are Korean and follow the existing template; copy one (`gh issue view 36 -R
  a2sys-platform/serving-team`, `... view 40 ...`):
  - Milestone: `<프로젝트> 프로젝트의 마일스톤입니다.` → `## 달성 기준` (a verifiable checkpoint,
    deadline included) → `## 참고` (ends with `이 마일스톤의 Epic은 sub-issue로 연결합니다.`).
  - Epic: `` `<Milestone 제목>` 마일스톤의 Epic입니다. `` → `## 완료 조건` (`작성 예정` when
    unknown) → `## 참고` (ends with `이 Epic의 작업은 sub-issue로 연결합니다.`).
- Labels: a work issue carries `team:serving` plus its type label. Milestones and Epics carry
  none. Which project an item belongs to is the board's `Project` field.
- Assignee: the person doing the work; the issue author when nobody else is named.

## The Serving Board

Org project #2, node id `PVT_kwDOEUH-BM4Bk1U-`. gh needs the `project` scope; when a call
fails on it, ask the user to run `! gh auth refresh -h github.com -s project`.

- Auto-add workflows place every new issue of serving-team, model-profiler, infrastructure,
  portal and argo-apps, and every sub-issue, on the board. The status workflows (item closed,
  PR linked, PR merged) are off: **every Status change is manual**.
- PRs stay off the board. An issue's Status carries its PR's progress.
- Board item of an issue: `issue { projectItems(first:10) { nodes { id project { number } } } }`
  (pick `number: 2`). Missing → `addProjectV2ItemById`.
- Field and option ids: query `projectV2(number:2) { fields }`; set Project, Status, Sprint,
  Workstream and Component with `updateProjectV2ItemFieldValue` (`singleSelectOptionId`,
  `iterationId`).
- Start date and Target date (like Priority and Effort) are org issue fields, not project
  fields, though the board shows them. The project mutation refuses them ("Issue field
  values cannot be updated using the updateProjectV2ItemFieldValue mutation"). Set them on
  the issue with `updateIssueFieldValue(input: {issueId, issueField: {fieldId, dateValue:
  "YYYY-MM-DD"}})`; Start `IFD_kgDOAoy0ow`, Target `IFD_kgDOAoy0pA` (from
  `organization(login:"a2sys-platform") { issueFields }`). Read back through
  `issue { issueFieldValues }`.

| Field | Rule |
|---|---|
| Project | One value per Milestone tree: the Milestone, its Epics and their work issues share it, whatever repository each lives in. A new option needs the user's approval; add it with `updateProjectV2Field`, passing every existing option with its `id` (options sent without ids drop the values already set on items). |
| Status | New issue: `Backlog`, or `Todo` once it has a Sprint. Branch cut or PR opened: `In Progress`. Waiting on someone outside the work: `Blocked`, with a comment naming the wait. Closed as completed: `Done`. `In Review` follows marking a PR ready, which is the user's action; set it when the user does so. Milestone/Epic: `In Progress` when its first child goes In Progress. |
| Start date / Target date | Milestone and Epic: both, always (the 로드맵 view shows only these two types). Target = the deadline in `달성 기준` or one the user gives; with neither, ask. Start = the planned start the user gives, else the day the first child goes In Progress. Work issue: Start = the day it goes In Progress; Target only when the user or the parent sets one. |
| Sprint | 1-week iterations starting Monday. Set only to a sprint the user names. |
| Workstream / Component | Set when an existing option plainly fits (the Workstream options are OpenRouter's). Priority and Effort have no options; leave them. |

## Dependencies (blocked by / blocking)

Set a new issue's GitHub issue dependencies when it is created, together with its parent and
board fields.

- **Hard dependencies only.** Use `blocked by` when the issue cannot proceed, or cannot close,
  until the other issue closes. A preferred order goes in the body as prose, not as a relation.
  "Fewer conflicts if #N merges first" and "better after the split" are examples.
- **Building on unmerged work is a hard dependency.** An issue may change code that so far
  exists only in an open PR, or its background may cite that PR as the base it builds on. It is
  then blocked by that PR's issue, even when its body never says "wait".
- **Both directions.** Record what the new issue waits on, and also what already-open issues wait
  on it.
- **Where to look.** Read the bodies, not only the titles, of every open issue in the
  repository the new issue lives in, including issues with no PR. Also check the parent Epic's
  other children and any issue the body names. Search other repositories only when the body
  names one of their issues.
- **API** (REST). `issue_id` is the blocker's database `.id`, not its number. Cross-repository
  blockers work.
  - add: `POST repos/<o>/<r>/issues/<blocked>/dependencies/blocked_by -F issue_id=<id>`
  - read: `GET .../dependencies/blocked_by`, `GET .../dependencies/blocking`
  - remove: `DELETE .../dependencies/blocked_by/<id>`
- **A pull request cannot be the blocker.** The API answers 422 "Target issue may only be an
  issue". Block on the issue the PR will close, if its `closingIssuesReferences` lists one. That
  list holds keyword links and links made from the PR's Development sidebar. If the PR closes
  nothing, write the wait into the body (`선행: #N 머지`).
- **Blocker not created yet**, e.g. an issue in a repository that does not exist yet: write the
  pending edge into the issue or Epic body, and add the relation once the blocker exists.
- A relation shows on both issues. When one lands on an issue someone else owns, tell the user.

## Creating a work issue

1. Find the parent Epic among serving-team's open Epics. None fits → propose the Epic (and
   Milestone, if needed) with its title and criteria, and wait for the user.
2. Create the issue with its type, labels and assignee.
3. Attach it: `POST repos/a2sys-platform/serving-team/issues/<epic>/sub_issues -F
   sub_issue_id=<id>`, where `<id>` is the REST `.id` of the issue (the database id, not its
   number).
4. On the board: Project = the parent's value, Status, and dates per the table.
5. Set its dependencies (§ Dependencies).

Done when one GraphQL read-back shows parent, type, `team:serving`, assignee, Project and
Status all set, and the dependency read-back (`blocked_by`, `blocking`) shows the intended
edges.

## Creating a Milestone or Epic

Create it via REST with `"type": "Milestone"` / `"Epic"` and the template body, attach an Epic
to its Milestone, then set Project, Status, Start date and Target date. When an Epic waits on
another Epic, set that dependency too (§ Dependencies). Done when the read-back shows the type,
the parent, all four fields, and any dependency.

## Opening a PR

- **Linking**: a closing keyword (`Closes #N`) in the PR body links the PR to the issue only
  when the PR's base is the default branch, and merging that PR closes the issue. So:
  - the PR that finishes the issue carries `Closes #N`;
  - a PR that does part of it carries `Refs #N`, and the last one carries `Closes #N`;
  - a PR stacked on another feature branch cannot link; the PR that lands in the default branch
    carries the keyword.
- Verify with `gh pr view <n> --json closingIssuesReferences`. Empty despite the keyword →
  PATCH the byte-identical body (`gh api .../pulls/<n> --jq .body | head -c -1` → `jq
  --rawfile`) so GitHub parses it again; confirm the body hash is unchanged.
- The issue goes `In Progress`, with its Start date if unset.

## Closing

- Closed as completed → `Done`. Every child of its Epic closed → propose closing the Epic;
  closing a Milestone or Epic is the user's call.
- After a close, read what the issue was blocking (`GET .../dependencies/blocking`). Tell the
  user which issues no longer have an open blocker.
- An issue closed as not planned or duplicate stays out of the tree: a closed sub-issue counts
  toward the Epic's progress whatever the close reason.
