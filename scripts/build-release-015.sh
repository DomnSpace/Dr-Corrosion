#!/usr/bin/env bash
set -euo pipefail

: "${PRIVATE_SOURCE_SHA:?}"
: "${FUNCTIONAL_SHA:?}"
: "${ARKADEON_SHA:?}"
: "${PUBLIC_BASE:?}"
: "${R04_URL:?}"
: "${R17_URL:?}"
: "${THEME_WAV_URL:?}"
: "${THEME_MASTER_BYTES:?}"
: "${THEME_MASTER_SHA256:?}"
: "${VERSION:?}"

cd source
test "$(git rev-parse HEAD)" = "$PRIVATE_SOURCE_SHA"
git merge-base --is-ancestor "$FUNCTIONAL_SHA" "$PRIVATE_SOURCE_SHA"
mapfile -t CHANGED < <(git diff --name-only "$FUNCTIONAL_SHA" "$PRIVATE_SOURCE_SHA")
for path in "${CHANGED[@]}"; do
  case "$path" in
    docs/RELEASE_NOTES_0.1.5.md|packaging/arkadeon_cartridge.json|packaging/build_manifest.json|tests/test_theme_runtime_reproduction.py|tests/test_release_candidate.py|tools/reproduce_theme_runtime_audio.py) ;;
    *) echo "Unexpected post-acceptance source change: $path"; exit 1 ;;
  esac
done

python -m compileall -q dr_corrosion.py surge_spool.py dr_music.py research_harvester.py gameboy_art.py lab_rooms.py labgraph experimental_lab dr_runtime dr_soundtrack tests
python -m py_compile tools/stage_theme_runtime_audio.py tools/reproduce_theme_runtime_audio.py tools/build_music_ready_release.py
node --check music/dr_corrosion.strudel.js
node --check music/demo/music-readiness-015-pass8.js
python -m pytest -q
node --test tests/test_feedback.cjs
python -m dr_runtime.fresh_player --fresh-player-acceptance
python -m dr_runtime.release_acceptance
python tools/release_performance_smoke.py
python -m labgraph validate
python -m experimental_lab validate
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
python -m labgraph native-check
python tools/check_hosted_arkadeon_shell.py
python tools/materialize_release_seed.py --r04-url "$R04_URL"
python tools/check_hosted_r17.py "$R17_URL" --origin https://domnspace.github.io

rm -rf .release-master .release-audio dist-stable
mkdir -p .release-master .release-audio
curl --fail --location --retry 4 --retry-all-errors --retry-delay 2 --connect-timeout 20 --output .release-master/theme.wav "$THEME_WAV_URL"
test "$(stat -c %s .release-master/theme.wav)" = "$THEME_MASTER_BYTES"
echo "$THEME_MASTER_SHA256  .release-master/theme.wav" | sha256sum -c -

docker run --rm -v "$PWD:/repo" -w /repo debian:13-slim bash -lc '
  set -euo pipefail
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ffmpeg python3 >/dev/null
  python tools/reproduce_theme_runtime_audio.py --master .release-master/theme.wav --output-dir .release-audio
'

test "$(stat -c %s .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.m4a)" = 6902360
test "$(stat -c %s .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.opus)" = 5292011
echo '68e4497d20814b9c7be5e39c3d0052e6776e22d987dd42ba23878212284c0449  .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.m4a' | sha256sum -c -
echo '78f309b27ecc0d60c07970744df16c6046f952ea55571eff7661b7c198326746  .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.opus' | sha256sum -c -

python tools/build_music_ready_release.py \
  --version "$VERSION" \
  --channel stable \
  --output-dir dist-stable \
  --index-url "$PUBLIC_BASE/stable/cartridge-index.json" \
  --cartridge-url "$PUBLIC_BASE/stable/dr-corrosion.drc" \
  --r17-url "$R17_URL" \
  --r17-metadata-only \
  --theme-audio .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.m4a \
  --theme-audio .release-audio/dr-corrosion-alles-im-gruenen-bereich-0.1.5.opus

python - <<'PY'
import json, os, zipfile
from pathlib import Path
from tools.build_music_ready_release import verify_packaged_audio
root = Path('dist-stable')
drc = root / f"dr-corrosion-{os.environ['VERSION']}.drc"
verified = verify_packaged_audio(drc)
assert sum(int(row['bytes']) for row in verified) == 12_194_371
with zipfile.ZipFile(drc, 'r') as archive:
    assert not any(name.lower().endswith('.wav') for name in archive.namelist())
    manifest = json.loads(archive.read('cartridge.json'))
    assert manifest['version'] == os.environ['VERSION']
info_path = root / 'build-info.json'
info = json.loads(info_path.read_text(encoding='utf-8'))
info.update({
    'source_commit': os.environ['PRIVATE_SOURCE_SHA'],
    'functional_base_commit': os.environ['FUNCTIONAL_SHA'],
    'arkadeon_host_commit': os.environ['ARKADEON_SHA'],
    'distribution_repository': os.environ['GITHUB_REPOSITORY'],
    'distribution_commit': os.environ['GITHUB_SHA'],
    'promotion': 'public-stable-music-readiness',
    'public_base': os.environ['PUBLIC_BASE'],
    'theme_master_sha256': os.environ['THEME_MASTER_SHA256'],
    'theme_master_bytes': int(os.environ['THEME_MASTER_BYTES']),
    'runtime_audio_bytes_required': 12_194_371,
})
info_path.write_text(json.dumps(info, indent=2, sort_keys=True) + '\n', encoding='utf-8')
PY

cd ..
rm -rf release-assets public
mkdir -p release-assets public/stable
cp "source/dist-stable/dr-corrosion-$VERSION.drc" release-assets/dr-corrosion.drc
cp source/dist-stable/cartridge-index.json release-assets/cartridge-index.json
cp source/dist-stable/build-info.json release-assets/build-info.json
cp RELEASE_NOTES_0.1.5.md release-assets/RELEASE_NOTES_0.1.5.md
cp site/index.html public/index.html
cp RELEASE_NOTES_0.1.5.md public/RELEASE_NOTES_0.1.5.md
cp release-assets/dr-corrosion.drc public/stable/dr-corrosion.drc
cp release-assets/cartridge-index.json public/stable/cartridge-index.json
cp release-assets/build-info.json public/stable/build-info.json
touch public/.nojekyll
