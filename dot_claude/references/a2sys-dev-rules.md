# A2SYS engineering rules (a2sys-platform repositories only)

Injected automatically by a hook in `~/.claude/settings.json`, and **only when `origin` points
at `a2sys-platform`**. Not loaded in any other repository.

Source of truth — read the originals for anything not covered here. The pages are in Korean;
this file is the agent-facing digest, reduced to what gates an action.

- [Git 브랜치 전략 (branch strategy)](https://a2sys.atlassian.net/wiki/x/AoAqAg)
- [개발 워크플로 (dev workflow: issue → PR → merge)](https://a2sys.atlassian.net/wiki/x/A4BQAg)
- Referenced by those: [릴리즈 & Hotfix 배포](https://a2sys.atlassian.net/wiki/spaces/a2sys/pages/39616554),
  [GitHub 저장소 보호 설정](https://a2sys.atlassian.net/wiki/spaces/a2sys/pages/38830116)

## Gates before starting

- **No branch and no PR without an issue.** Every change to code — feature, fix, bug,
  refactor — starts from a GitHub Issue. If none exists, propose creating one and do not cut
  a branch until it exists. Label the issue by type (`feature`, `bug`, `refactor`, `docs`, …).
- **Every issue joins the tracking tree** (parent Epic in `serving-team`, Serving Board fields).
  Creating an issue, Milestone or Epic, starting work on one, or closing one: follow
  `~/.claude/references/a2sys-issue-tracking.md`.
- **Never push directly to `develop` or `main`.** No exceptions.

## Branches

Each project picks Git Flow or Trunk-Based and then applies it consistently. For a Git Flow
repository:

| Branch | Cut from | Example |
|---|---|---|
| `main` | — | released, always-deployable (**not** `master`) |
| `develop` | `main` | integration |
| `feature/*` | `develop` | `feature/#123-login-oauth` |
| `fix/*` | `develop` | `fix/#128-token-expiry` (**not** `bugfix/`) |
| `hotfix/*` | **`main`** | `hotfix/#130-payment-500` |
| `release/*` | `develop` | `release/1.2.0` (version, not an issue number) |

Naming is `<type>/#<issue>-<short-description>` in kebab-case. This matches git-flow CLI
defaults except in two places: the production branch is `main`, and bug fixes use `fix/`.

## PR

- **Title follows [Conventional Commits](https://www.conventionalcommits.org)** — `feat`,
  `fix`, `docs`, `refactor`, `test`, `chore`. The branch prefix (`feature/`) and the commit
  type (`feat:`) are different words. `feature/*` → `develop` is a squash merge, so **the PR
  title becomes the single commit line on `develop`**.
- **Always open as a DRAFT** (`gh pr create --draft`). Marking it ready for review is the
  user's action, not mine — never open a non-draft PR and never flip one to ready, even when
  the work looks finished and CI is green. Opening as draft is a hard rule, not a default to
  weigh: a PR going ready is what pages a reviewer, and that call belongs to the person whose
  name is on it.
- **Body**: follow the repository's `.github/pull_request_template.md`. If there is none, use
  What / Why (`Closes #N`) / How / How tested / checklist (self-review, tests added or
  updated, CI green, docs updated).
- **Link the issue and move it on the board**: `Closes #N` only on the PR that finishes the
  issue, then verify the link and set the issue `In Progress` —
  `~/.claude/references/a2sys-issue-tracking.md` § Opening a PR.
- Keep PRs small and frequent.

## Review

- At least one approving review is required. **A repository unavoidably staffed by one person
  is exempt from the approval only** — issue, branch, PR, CI and comment resolution all still
  apply.
- **Only the reviewer resolves review comments. The author (me or the user) does not.**
- Either address a comment or reply explaining why it will not be addressed.

## Merge — the method depends on the path

| Path | Method |
|---|---|
| `feature/*` → `develop` | **Squash merge** |
| `develop` → `main` | Plain merge (merge commit) |
| `hotfix/*` → `main` | Plain merge (merge commit) |
| `main` → `develop` (back-merge) | Plain merge (merge commit) |

Squashing or rebasing on any `main`-related path leaves the same fix as different commits on
`main` and `develop`, which then conflicts at the next release merge. CI is a required status
check, so a red build blocks the merge button.

## Applying these

- An existing repository may already deviate (branch names, work without issues, and so on).
  When that turns up, **do not quietly correct it — tell the user and let them decide.**
- Commit, PR and merge only when the user explicitly asks.
