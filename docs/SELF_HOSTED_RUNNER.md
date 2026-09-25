# Self-hosted GitHub Actions runner

## Why

The repo is public, so GitHub-hosted minutes are already unlimited -- this
runner is about **speed, not cost**: a persistent `~/.elan` + pip cache on
the runner means no re-downloading the 7.4 GB Lean toolchain/deps on every
push. It also gives free, unlimited capacity for any private repos later.

The runner lives on the Windows 11 box, in WSL (Ubuntu 24.04). It registers
against **this repo only** (`chokmah-me/fragile-proof-audit`).

## Setup (run in the WSL Ubuntu terminal)

The exact download URL / token below comes from the repo's
Settings > Actions > Runners > "New runner" page (token is single-use,
expires quickly -- get a fresh one if these commands fail at `config.sh`).

```bash
# 1. Enable systemd in WSL (needed for the runner service), then restart WSL:
#    in /etc/wsl.conf add:
#      [boot]
#      systemd=true
#    then from PowerShell:  wsl --shutdown

# 2. Install and configure the runner
mkdir ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-<VERSION>.tar.gz -L <DOWNLOAD-URL>
echo "<SHA256>  actions-runner-linux-x64-<VERSION>.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-<VERSION>.tar.gz
./config.sh --url https://github.com/chokmah-me/fragile-proof-audit --token <TOKEN>

# 3. Test once in the foreground
./run.sh        # Ctrl+C after it prints "Listening for Jobs"

# 4. Install as a service so it survives reboots
sudo ./svc.sh install
sudo ./svc.sh start
```

Verify: repo Settings > Actions > Runners shows the runner green/idle.
Then merge the `selfhosted-runner` branch into `main`.

## Security rule (do not change casually)

`verify.yml` routes **external pull requests to `ubuntu-latest`** and only
pushes/schedules to `self-hosted`. Never point a PR-triggered job at the
self-hosted runner: a fork PR could execute arbitrary code on the Windows box.

## Maintenance

- If the runner is offline > 14 days GitHub drops it: re-run `config.sh`
  with a fresh token from the "New runner" page (no need to reinstall).
- Update the runner when GitHub prompts: `./run.sh` prints a notice;
  `sudo ./svc.sh stop`, re-extract the new tarball over the directory,
  `./svc.sh start`.
- Disk: keep ~15 GB free (elan toolchains + lake build cache + repo).
