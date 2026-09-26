# setup-ubuntu

Script de configuração pessoal do Ubuntu — automatiza a instalação e o visual do meu ambiente (GNOME + tema vermelho minimalista + kitty + oh-my-posh).

## O que ele faz?

- Atualiza o sistema e habilita os repositórios `universe`/`multiverse`
- Instala pacotes básicos: `git`, `curl`, `build-essential`, `flatpak`, `gnome-tweaks`, `kitty`, `fastfetch`, etc.
- Instala a Nerd Font **JetBrainsMono**
- Instala e configura o **oh-my-posh** com o tema `atomic.omp.json`
- (Modo `--full`) Instala apps do dia a dia via Flatpak: VSCode, Discord, Spotify, Telegram e OBS Studio

## Requisitos:

- Ubuntu (ou derivado baseado em `apt`)
- Usuário com acesso a `sudo`
- Conexão com a internet

## Como usar

```bash
git clone https://github.com/Lucas4411/dotfiles-ubuntu.git
cd setup-ubuntu
chmod +x setup-ubuntu.sh
./setup-ubuntu.sh
```

### Flags disponíveis

| Flag         | O que faz                                              |
|--------------|---------------------------------------------------------|
| `--full`     | Instala tudo, incluindo os apps extras (padrão)         |
| `--minimal`  | Instala só o essencial (shell, terminal, fontes, prompt)|
| `--help`     | Mostra a lista de opções                                |

Exemplo:

```bash
./setup-ubuntu.sh --minimal
```

## Depois de rodar

O script cuida da parte de instalação, mas alguns ajustes visuais ainda são manuais:

1. Reinicie o terminal ou rode `source ~/.bashrc`
2. Copie `kitty.conf` para `~/.config/kitty/kitty.conf`
3. Copie `config.jsonc` para `~/.config/fastfetch/config.jsonc`
4. Abra o **GNOME Tweaks** / **Extension Manager** para aplicar o restante do tema
5. Rode `fastfetch` para conferir o resultado

## Estrutura do repositório

```
.
├── setup-ubuntu.sh   # script principal
├── kitty.conf         # config do terminal (tema vermelho, fundo transparente)
├── config.jsonc        # config do fastfetch
└── README.md
```

## Aviso⚠️

Este script é feito com base no meu uso e gosto. Sinta-se à vontade pra usar como base para o seu próprio script, antes de usar ele, revise pois ele mexe em pacotes do sistema e arquivos de configuração do usuário.
