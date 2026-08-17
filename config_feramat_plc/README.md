# FERAMAT PLC – Initial Setup

Tento postup slouží pro prvotní konfiguraci nového PLC s Debianem.

Setup script provede:

* aktualizaci systému pomocí `apt`
* instalaci nástrojů:

  * `vim`
  * `tcpdump`
  * `nmap`
  * `tmux`
  * `curl`
* instalaci konfigurace Vimu
* instalaci konfigurace tmux
* instalaci Bash aliasů a barevného promptu
* nastavení názvu PLC zobrazovaného v promptu
* instalaci veřejného SSH klíče
* instalaci FERAMAT MOTD

## 1. Přihlášení na nové PLC

Přihlaste se na PLC pomocí PuTTY nebo SSH.

Například:

```bash
ssh unipi@192.168.1.23
```

## 2. Stažení setup scriptu

Na PLC spusťte:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/PokornyPavel/ConfigFiles/refs/heads/main/config_feramat_plc/setup_plc.sh \
  -o setup_plc.sh
```

## 3. Kontrola staženého scriptu

Ověřte, že soubor není prázdný:

```bash
ls -lh setup_plc.sh
```

Případně si jeho obsah prohlédněte:

```bash
less setup_plc.sh
```

## 4. Nastavení spustitelnosti

```bash
chmod +x setup_plc.sh
```

## 5. Kontrola verze

```bash
./setup_plc.sh --version
```

## 6. Spuštění instalace

Setup script vyžaduje název PLC.

Syntaxe:

```bash
./setup_plc.sh PLC_NAME
```

Například:

```bash
./setup_plc.sh XXX_YYY_ZZZ_PLC
```

Povolené znaky v názvu PLC:

```text
A-Z
a-z
0-9
_
-
.
```

Název PLC se bude zobrazovat v Bash promptu.

Například:

```text
[unipi@hostname|XXX_YYY_ZZZ_PLC: ~]
```

## 7. Aktivace nové konfigurace

Po dokončení instalace spusťte:

```bash
source ~/.bashrc
```

nebo se z PLC odhlaste a znovu přihlaste.

## 8. Základní kontrola

Zkontrolujte instalované konfigurační soubory:

```bash
ls -lh \
  ~/.vimrc \
  ~/.bash_aliases \
  ~/.tmux.conf \
  ~/.plc_name \
  ~/.ssh/authorized_keys
```

Zkontrolujte název PLC:

```bash
cat ~/.plc_name
```

Zkontrolujte SSH klíče:

```bash
cat ~/.ssh/authorized_keys
```

## Opětovné spuštění

Setup script lze spustit znovu.

Například:

```bash
./setup_plc.sh XXX_YYY_ZZZ_PLC
```

Konfigurační soubory stažené z GitHubu budou nahrazeny aktuální verzí.

SSH veřejný klíč nebude do `authorized_keys` přidán podruhé, pokud již existuje.

## Umístění konfigurace na GitHubu

```text
ConfigFiles/
├── .vimrc
├── .tmux.conf
└── config_feramat_plc/
    ├── README.md
    ├── setup_plc.sh
    ├── .bash_aliases
    ├── pokorny.pub
    └── CHANGELOG.md
```

## Umístění konfigurace na PLC

```text
~/.vimrc
~/.tmux.conf
~/.bash_aliases
~/.plc_name
~/.ssh/authorized_keys
```

`pokorny.pub` se na PLC trvale neukládá. Setup script jej pouze dočasně stáhne, ověří a přidá jeho obsah do:

```text
~/.ssh/authorized_keys
```
