#!/usr/bin/env bash
#
# script-pos-instalacao.sh - Instala programas de forma automática
#
# Site:       https://
# Autor:      Roberto Alves Pacheco
# Manutenção: Roberto Alves Pacheco
#
# ------------------------------------------------------------------------ #
#  Este programa irá instalar os programas elencados na variável 'lista_programas' quando chamado.
#  O objetivo é automatizar a tarefa de instalar programas após instalar o SO.
#  
#
#  Exemplos:
#
#      $ ./script-pos-instalacao.sh
#
#      Neste exemplo o script será executado....
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 03/Jun/2021, Roberto:
#       - Início do programa
#       - Finalizado versão "ma ou meno...rs"

#   v2.0 09/Jun/2021, Roberto:
#       - Refeito o programa para ficar mais completo e interativo!

#	v2.1 11/Jun/2021, Roberto:
#		- Realizado comentários no código e anexado suporte a Flatpaks
#
#	v2.2 11/Jun/2021, Roberto:
#		- Feito ajuste para baixar e instalar o .deb Visual Studio code
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.0.17(1)-release (x86_64-pc-linux-gnu)
# ------------------------------------------------------------------------ #
# Agradecimentos:
#
# 	Diolinux - Copiei parte dos códigos dele em:
#      https://github.com/Diolinux/Linux-Mint-19.x-PosInstall.git

# ------------------------------------------------------------------------ #

# -------------------------PROGRAMAS APTs CONTEMPLADOS------------------------- #
# chrome .deb
# git
# nixnote2
# vim
# dropbox
# snapd
# virtualbox
# audacious
# vlc
# tilix
# pomodoro (gnome-shell-pomodoro)
# gparted
# flatpak
# code (visual studio code)	.deb
# librecad
# flameshot
lista_programas=('flameshot' 'code' 'flatpak' 'google-chrome*' 'git' 'nixnote2' 'vim' 'dropbox' 'snapd' 'virtualbox'
	'audacious' 'vlc' 'tilix' 'gnome-shell-pomodoro*' 'gparted' 'elisa' 'librecad')

# ------------------------------------------------------------------------ #
# -------------------- PROGAMAS FLATPAKs CONTEMPLADOS ---------------------#
#
# Video Downloader
# PyCharm-Community
# Spotify
# Sublime Text
#
#
# Gimp - Programa de manipulação de imagem do GNU

programas_flatpaks=('com.github.unrud.VideoDownloader' 'com.jetbrains.PyCharm-Community'
'com.spotify.Client' 'com.sublimetext.three' 'org.gimp.GIMP')

# ------------------------------- VARIÁVEIS------------------------------- #
## Url para download Google chrome (para programas fora dos repo oficiais da distro)
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

URL_CODE='https://go.microsoft.com/fwlink/?LinkID=760868'

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"

TAMANHO_LISTA=${#lista_programas[@]}



# ------------------------------- REQUISITOS------------------------------ #

## Removendo travas eventuais do apt, redireciona saída para buraco negro! ##
sudo rm /var/lib/dpkg/lock-frontend > /dev/null

sudo rm /var/cache/apt/archives/lock > /dev/null

## Atualizando os repositórios
sudo apt update -y

## Para programas fora do apt que precisam ser baixados o .deb
mkdir "$DIRETORIO_DOWNLOADS"

wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"

## --content... É necessário para baixar o .deb com nome correto do vscode.
## obs. -O code.deb = Renomeia o arquivo baixado
wget -c --content-disposition "$URL_CODE" -P "$DIRETORIO_DOWNLOADS"

# ------------------------------- EXECUÇÃO ------------------------------- #
echo "======================================================================"

## Faz um loop na lista de programas e verifica se o programa está ou não
## instalado. Em caso negativo, salva o nome do programa no arquivo
## programas_instalar no diretório de uso temporário.

for i in ${lista_programas[@]}; do
	dpkg -l $i &> /dev/null
	if test $? -eq 0; then
		echo "O programa $i já está instalado."
	else
		echo "---------------------------------------------------"
		echo "O programa $i NÃO ESTÁ instalado."
		echo "---------------------------------------------------"
		echo $i >> /tmp/programas_instalar.txt
		chmod a+rwx /tmp/programas_instalar.txt
	fi
done

## O comando 'wc -l' é um contador de linhas (counter word)
## Assim, cada linha do arquivo representa um programa que deve ser
## instalado.
QTDE_PROGRAMAS_INSTALAR=$(cat /tmp/programas_instalar.txt | wc -l)


## Aqui o código verifica a quantidade de programas a instalar, se
## for 0, saí sem fazer nada com código de saída 0
## Se houver linhas no arquivo, faz um loop para mostrar linha por linha
## os programas a instalar
if test $QTDE_PROGRAMAS_INSTALAR -eq 0; then
	echo "Todos os programas APT contemplados estão instalados."
	echo "--------------------------------------------------------------"
	# exit
else
	echo "Falta instalar o(s) programa(s) a seguir: "
	ARQUIVO=$(cat /tmp/programas_instalar.txt)
	for programa in $ARQUIVO; do
		echo "**** $programa ****"
	done
fi

read -p "Deseja instalá-los? [s=Instalação pacotes apt / n=rodar script Flatpaks] " RESPOSTA

if test $RESPOSTA = 's'; then
	# Instala todos os programas .deb baixados no diretório citado
	sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

	for programa in $ARQUIVO; do
		sudo apt install $programa -y
	done
else
	echo "Tenha um bom dia! :-) "
	rm /tmp/programas_instalar.txt > /dev/null
fi
rm /tmp/programas_instalar.txt > /dev/null

read -p "Deseja instalar os programas Flatpaks? [s/n] " RESPOSTA
	if test $RESPOSTA = 's'
	then
		for programa in ${programas_flatpaks[@]}
		do
			if flatpak info $programa > /dev/null
			then
				echo "O programa $programa Flatpak já está instalado"
			else
				echo "Instalando o programa $programa Flatpak..."
				flatpak install $programa
			fi
		done
		echo "Todos os flatpaks contemplados já estão instalados!"
		echo "Tenha um excelente dia! :-) "
	else
		echo "--------------------------------------------------------"
		echo "Tenha um excelente dia! :-) "
		echo "--------------------------------------------------------"
	fi
## Atualiza todo o sistema antes de encerrar o script
sudo apt update && sudo apt upgrade -y
flatpak update -y
sudo snap refresh
sudo apt autoclean
sudo apt autoremove -y

## Finaliza o script em grande estilo!
echo
echo "-----------------------------------------------------"
echo "Todos os programas foram instalados!"
echo "O sistema está atualizado"
