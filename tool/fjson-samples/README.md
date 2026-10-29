# fjson samples

Input payloads for the Dart beans generated with `fjson-cli`
(`../fjson-cli` in this workspace, `./gradlew jar` → `build/libs/fjson-cli.jar`,
or a `fjson` wrapper on `PATH`).

These files are codegen inputs, not app code: they live outside `lib/` so they
can never be compiled or bundled into a build, and they stay committed because
the tests parse them byte for byte — the bean and the tests are pinned to one
real payload.

## github_releases_latest.json

A real `GET https://api.github.com/repos/K3vinb5/Unyo/releases/latest`
response, trimmed to the fields the app reads. It produces
`lib/core/services/api/dto/github/github_release_entity.dart`. Run both commands
from the Flutter project root (`unyo-app/`):

```bash
fjson bean \
  --class GithubReleaseEntity \
  --file tool/fjson-samples/github_releases_latest.json \
  --output lib/core/services/api/dto/github/

fjson gen --project .
```

`bean` writes the bean (`--suffix entity`, the default); `gen` rewrites
`lib/generated/json/github_release_entity.g.dart`. Neither file is hand-edited:
regenerate and commit both together with any sample change. Replacing the sample
with a newer release payload also means updating the expectations in
`test/core/services/update/update_checker_service_test.dart`.
