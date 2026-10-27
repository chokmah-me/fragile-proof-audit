#!/usr/bin/env bash
# One-shot GitLab sweep for CVE-2026-110264. Report-only, always exit 0.
# Checks the WSL guest this runner lives in, plus the Windows host via
# /mnt/c targeted paths and powershell.exe interop when available.
FOUND=0
note() { echo "$1"; echo "$1" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"; }
hit() { FOUND=1; note "FOUND: $1"; }
miss() { note "clean: $1"; }

note "## GitLab sweep on $(hostname) ($(uname -srm))"
note "date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# --- WSL / Linux side ---
if command -v gitlab-ctl >/dev/null 2>&1 || command -v gitlab-rake >/dev/null 2>&1 || command -v gitlab-rails >/dev/null 2>&1; then
  hit "gitlab binaries in PATH"
else
  miss "no gitlab binaries in PATH"
fi

for d in /opt/gitlab /etc/gitlab /var/opt/gitlab /srv/gitlab; do
  if [ -e "$d" ]; then hit "directory exists: $d"; fi
done
[ -e /opt/gitlab ] || [ -e /etc/gitlab ] || miss "no standard GitLab directories"

if command -v dpkg >/dev/null 2>&1; then
  if dpkg -l 2>/dev/null | grep -qi gitlab; then hit "dpkg package matching gitlab"; else miss "no gitlab dpkg packages"; fi
fi
if command -v rpm >/dev/null 2>&1; then
  if rpm -qa 2>/dev/null | grep -qi gitlab; then hit "rpm package matching gitlab"; fi
fi
if command -v snap >/dev/null 2>&1; then
  if timeout 15 snap list 2>/dev/null | grep -qi gitlab; then hit "snap package matching gitlab"; fi
fi

if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-units --all --no-legend 2>/dev/null | grep -qi gitlab; then hit "systemd unit matching gitlab"; else miss "no gitlab systemd units"; fi
fi

if ps aux 2>/dev/null | grep -i '[g]itlab' | grep -qv 'gitlab-sweep'; then
  hit "running process matching gitlab"
else
  miss "no gitlab processes"
fi

if command -v docker >/dev/null 2>&1; then
  if docker ps -a --format '{{.Image}} {{.Names}}' 2>/dev/null | grep -qi gitlab; then hit "docker container matching gitlab"; fi
  if docker images --format '{{.Repository}}' 2>/dev/null | grep -qi gitlab; then hit "docker image matching gitlab"; fi
  miss "docker checked"
else
  miss "docker not present"
fi
if command -v podman >/dev/null 2>&1; then
  if podman ps -a --format '{{.Image}} {{.Names}}' 2>/dev/null | grep -qi gitlab; then hit "podman container matching gitlab"; fi
fi

# Bounded filesystem spot check (WSL side, depth-limited)
FSHITS="$(find /opt /srv /usr/local /home -maxdepth 4 -iname '*gitlab*' 2>/dev/null | grep -v 'fragile-proof-audit' | head -20)"
if [ -n "$FSHITS" ]; then hit "filesystem paths matching gitlab: $FSHITS"; else miss "no gitlab paths in bounded WSL filesystem check"; fi

# --- Windows host side (runner lives in WSL2 on a Windows box) ---
if [ -d /mnt/c ]; then
  WHITS=""
  for p in "/mnt/c/GitLab" "/mnt/c/Program Files/GitLab" "/mnt/c/Program Files (x86)/GitLab" "/mnt/c/ProgramData/GitLab"; do
    [ -e "$p" ] && WHITS="$WHITS $p"
  done
  if [ -n "$WHITS" ]; then hit "Windows paths present:$WHITS"; else miss "no GitLab paths in targeted Windows locations"; fi
  # Note: C:\gitlab-runner would be the GitHub-style agent analogue for
  # GitLab CI, a runner agent, not a GitLab CE/EE server; it is recorded
  # via the powershell service check below, not counted as a hit here.
else
  note "skip: /mnt/c not mounted, Windows side not checked from here"
fi

if command -v powershell.exe >/dev/null 2>&1; then
  PSOUT="$(timeout 60 powershell.exe -NoProfile -NonInteractive -Command "Get-Service | Where-Object { \$_.Name -match 'gitlab' } | Select-Object -ExpandProperty Name; Get-Process | Where-Object { \$_.ProcessName -match 'gitlab' } | Select-Object -ExpandProperty ProcessName; Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { \$_.DisplayName -match 'GitLab' } | Select-Object -ExpandProperty DisplayName" 2>/dev/null | tr -d '\r')"
  if [ -n "$PSOUT" ]; then hit "Windows service/process/installed-app matching GitLab: $PSOUT"; else miss "no Windows service, process, or installed app matching GitLab"; fi
  # Record GitLab Runner service separately: it is a CI runner agent, not a GitLab server.
  PSRUNNER="$(timeout 60 powershell.exe -NoProfile -NonInteractive -Command "Get-Service -Name 'gitlab-runner' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Status" 2>/dev/null | tr -d '\r')"
  if [ -n "$PSRUNNER" ]; then note "info: gitlab-runner service status: $PSRUNNER (runner agent, not a GitLab server; not in CVE scope)"; fi
else
  note "skip: powershell.exe interop unavailable, Windows services not checked"
fi

if [ "$FOUND" -eq 0 ]; then
  note "SWEEP_RESULT: CLEAN (no GitLab CE/EE install found on this box)"
else
  note "SWEEP_RESULT: FOUND (GitLab traces found, see FOUND lines above)"
fi
exit 0
