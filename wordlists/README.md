# 📚 Wordlists

Les wordlists ne sont pas stockées dans ce repo (trop lourdes).
Le script `setup/wordlists.sh` les télécharge et les organise automatiquement dans `~/wordlists/`.

---

## Structure après installation

```
~/wordlists/
├── passwords/
│   └── rockyou.txt
├── directories/
│   ├── common.txt
│   ├── medium.txt
│   └── big.txt
├── subdomains/
│   └── top5000.txt
├── usernames/
│   └── common.txt
├── fuzzing/
│   └── fuzz.txt
└── seclists/              ← SecLists complet
```

---

## Références

| Wordlist | Description | Lien |
|---|---|---|
| **SecLists** | La référence — directories, DNS, fuzzing, passwords… | https://github.com/danielmiessler/SecLists |
| **RockYou** | Classique pour le password cracking | Inclus dans Kali `/usr/share/wordlists/` |
| **CeWL** | Génère une wordlist custom depuis un site cible | https://github.com/digininja/CeWL |
| **Crunch** | Génère des wordlists par pattern | `apt install crunch` |
| **Assetnote** | Wordlists pour bug bounty (APIs, subdomains) | https://wordlists.assetnote.io |
