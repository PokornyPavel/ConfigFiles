# FERAMAT PLC Setup Changelog

## 1.3.1 — 2026-08-17

- Changed GitHub raw URL to use `/refs/heads/main`.
- Added safe download handling for `.vimrc`, `.bash_aliases` and `.tmux.conf`.
- Downloaded configuration files are first stored in temporary files.
- Empty downloaded files are rejected.
- Existing configuration files are replaced only after successful validation.
- Added additional validation for `pokorny.pub`.
- SSH public-key file must contain exactly one non-empty key line.

## 1.3.0 — 2026-08-17

- Moved SSH public key from `setup_plc.sh` to standalone `pokorny.pub`.
- PLC name is now a required argument.
- PLC name is stored locally in `~/.plc_name`.
- Bash prompt reads the PLC name dynamically.
- Added `--help`.
- Added `--version`.
- Added script version and release date.

Example:

```bash
./setup_plc.sh XXX_YYY_ZZZ_PLC