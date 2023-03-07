#!/bin/bash 

# Sources :
# https://openclassrooms.com/fr/courses/2035796-utilisez-ansible-pour-automatiser-vos-taches-de-configuration/6371875-preparez-la-communication-avec-les-nodes

# Installation de Ansible

# Mise à jour du système
apt install python-virtualenv sshpass

# Ajouter un user pour Ansible
adduser user-ansible

# Se connecter avec  user-ansible
su - user-ansible

# Créer l'environnement de travail virtuel
virtualenv ansible

# Activer l'environnement virtuel
source ansible/bin/activate

# Installer Ansible dans l'environnement de travail Ansible
pip install ansible

# Vérifiez la version de Ansible
ansible --version

# Voir les outils Ansible installés
ls -l ansible/bin/ansible* -l

#############################################

# Créer un fichier inventaire
vi inventaire.ini

# Autoriser temporairement les connexions ssh pour root pour installer les prérequis

# Enregistrer les fingerprint sur les nodes en lançant une connexion ssh


# Utiliser le ping en mode ad-hoc pour vérifier les connexions
ansible -i inventaire.ini -m ping srvfi --user root --ask-pass

# Vérifier que Python est installé sur les nodes
# Il arrive parfois que Python ne soit pas installé sur le node ; dans ce cas, nous
# pouvons utiliser un module spécial : raw, qui permet de passer des commandes Ansible
# sans utiliser Python
ansible -i inventaire.ini -m raw -a "apt install -y python3" srvfi --user root --ask-pass


# Générer un mot de passe haché et salé
ansible localhost -i inventaire.ini -m debug -a "msg={{ 'amadou' | password_hash('sha512','secretsalt') }}"
# résultat password : $6$secretsalt$LGVDubz3VABLI.iOKq/KV4gMNwLF29lAWBLUA6Ft0kt0fr4Ne32C.Ds7MYeJBGmBxNvxLWgVZNQIzDFSWods8/

# Créer un user Ansible sur les nodes en mode ad-hoc, avec le mot de passe salé qui vient d'être généré
ansible -i inventaire.ini -m user -a 'name=user-ansible shell=/bin/bash password=$6$secretsalt$LGVDubz3VABLI.iOKq/KV4gMNwLF29lAWBLUA6Ft0kt0fr4Ne32C.Ds7MYeJBGmBxNvxLWgVZNQIzDFSWods8/' --user root --ask-pass san

# Donner les droits sudo à user-ansible
ansible -i inventaire.ini -m user -a 'name=user-ansible groups=sudo append=yes ' --user root --ask-pass all
ansible -i inventaire.ini -m user -a 'name=user-ansible groups=sudo append=yes ' --user root --ask-pass san

# Vérifier que user-ansible a les droits sudo avec l'option become
ansible -i inventaire.ini -m user -a 'name=user-ansible groups=sudo append=yes ' --user user-ansible --ask-pass --become --ask-become-pass all

# A ce niveau, nous pouvons désactiver les connexions ssh pour root

# Création de clés ssh pour user-ansible
# Switcher avec user-ansible
su - user-ansible

# Création de clés ssh de type ecdsa
ssh-keygen -t ecdsa

# Ajout de la clé publique de user-ansible sur les nodes
ansible -i inventaire.ini -m authorized_key -a 'user=user-ansible state=present key="{{ lookup("file", "/home/user-ansible/.ssh/id_ecdsa.pub") }}"' --user user-ansible --ask-pass --become --ask-become-pass all
# il faudra saisir le mot de passe pour créer la clé hachée (de user-ansible) puis la passephrase pour créer la clé ssh ()
# dans notre cas, "amadou" pour le user-ansible et "la touche entrée" pour la passphrase

#####################################################
# Activer le ssh sur Windows Server
# Commandes PowerShell en mode super utilisateur
# Sources : http://woshub.com/connect-to-windows-via-ssh/

# Création des roles
mkdir roles ; cd roles
ansible-galaxy init apache
ansible-galaxy init mariadb
touch apache/tasks/php-install.yml

mkdir mediawiki
mkdir -p mediawiki/commun/defaults/
touch mediawiki/commun/defaults/main.yml

mkdir -p mediawiki/confdb/meta mediawiki/confdb/tasks
touch mediawiki/confdb/tasks/main.yml 
touch mediawiki/confdb/meta/main.yml

mkdir -p mediawiki/confapache/meta mediawiki/confapache/tasks 
touch mediawiki/confapache/tasks/main.yml mediawiki/confapache/meta/main.yml


ansible-playbook -i inventaire.ini --user user-ansible --become --ask-become-pass ~/play-book/deluser.yml
ansible-playbook -i inventaire.ini --user user-ansible --become --ask-become-pass ~/play-book/adduser.yml



ansible-playbook -i inventaire.ini --user user-ansible ~/play-book/adduser.yml
ansible-playbook -i inventaire.ini --user user-ansible ~/play-book/deluser.yml
ansible-playbook -i inventaire.ini --user user-ansible ~/play-book/deluser.yml

# Test GitHub
# Test user-ansible
# Test user-ansible2
