# Mon Dashboard

Bienvenue dans le projet de la création d'un dashboard sur le thème du jeu "League of Legends". Ce tableau de bord offre une visualisation interactive des données avec des fonctionnalités telles qu'un slider et listes déroulantes.

## User Guide

### Prérequis
- R doit être installé sur la machine.
- Assurez-vous d'avoir les packages nécessaires en exécutant `install.R` avant de lancer l'application.

### Déploiement

Pour déployer le tableau de bord sur une autre machine, suivez ces étapes :

1. Téléchargez ou clonez le dépôt sur votre machine.
2. Assurez-vous que R est installé.
3. Exécutez le script `install.R` pour installer les packages requis : `Rscript install.R`.
   - **Note :** Lancer le script `app.R` exécute automatiquement `install.R`.
4. Lancez l'application en exécutant le script `app.R`.
5. L'application sera accessible dans votre navigateur à l'adresse http://127.0.0.1:7340/

## Rapport d'Analyse

Le rapport d'analyse est disponible dans le fichier [Rapport_Analyse.pdf](Rapport_Analyse.pdf). Il met en avant les principales conclusions extraites des données.

## Developper Guide

### Architecture du Code

Le code est organisé comme suit :

- `app.R` : Fichier principal pour lancer l'application Shiny.
- `prepa.R` : Préparation des données.
- `install.R` : Installation des packages depuis `requirements.txt`.
- `data/`: Stocke les données utilisées par le tableau de bord. (Fichiers CSV)

`prepa.R` : (+ en détails) 
#### Chargement du DataFrame des pays :
	Le script commence par charger le DataFrame countries_df à partir du fichier CSV data/curiexplore-pays.csv. 
	Ce DataFrame contient des informations sur tous les pays du monde, telles que le nom en anglais (name_en), le code ISO 2 (iso2), les coordonnées géographiques (latlng), et des informations de région (central_america_caraibes et north_america).

#### Définition des exceptions (servers_bonus) :
	Ensuite, le script définit un dictionnaire appelé servers_bonus, qui contient des informations sur les serveurs avec des exceptions pour certains pays ou régions. Chaque élément du dictionnaire correspond à un serveur avec des détails tels que le nom (name), la liste des pays inclus (countries), et la relation avec les régions (relation).

#### Création du dictionnaire des informations des pays (pays_infos) :
	Le script parcourt chaque ligne du DataFrame countries_df pour construire le dictionnaire pays_infos. Chaque pays a des informations telles que le code ISO 2 (iso2), les coordonnées géographiques (latitude et longitude), et des relations avec certaines régions (central_america_caraibes et north_america).

#### Ajout des pays aux serveurs :
	Ensuite, le script parcourt les serveurs dans servers_bonus et, en fonction des relations spécifiées, ajoute les pays correspondants à chaque serveur.

#### Création du dictionnaire final des serveurs et des pays (servers_countries) :
	Le script crée un dictionnaire final appelé servers_countries, regroupant les informations des serveurs et des pays. Chaque élément du dictionnaire correspond à un serveur ou à un pays, avec des détails tels que le nom (name), la liste des pays inclus (countries), les coordonnées géographiques (latitude et longitude), et les coordonnées formatées (coord).
	
#### Retour du dictionnaire final :
	Enfin, le script retourne le dictionnaire final servers_countries, qui contient toutes les informations nécessaires pour les pays et les serveurs.

Ce script est crucial pour établir des relations entre les pays et les serveurs, en fournissant des informations géographiques et de région qui seront utilisées dans l'analyse ultérieure.

`app.R` : (+ en détails) 
#### Chargement des dépendances :
Le script commence par charger les packages et les scripts nécessaires, tels que install.R, shiny, dplyr, ggplot2, plotly, readr, et shinyjs. Ces packages sont essentiels pour le développement de l'application Shiny.

#### Préparation des données (prepa.R) :
Le script source le fichier prepa.R, qui contient les opérations de préparation des données. Ces opérations incluent le chargement des données sur les pays et les serveurs, la création de dictionnaires contenant des informations géographiques, et l'établissement de relations entre les pays et les serveurs.

#### Initialisation des variables :
Le script initialise différentes variables, telles que repertoire, seasons, seasons_int, et teams, nécessaires à la manipulation des données et à l'interaction avec l'interface Shiny. Il récupère également les années de saison disponibles à partir des fichiers CSV présents dans le répertoire "data".

#### Chargement des données des saisons :
Les données de chaque saison sont chargées à partir des fichiers CSV correspondants. Les noms des colonnes sont modifiés pour assurer la cohérence, et des prétraitements sont effectués, tels que la conversion du taux de victoire (winRate) en numérique.

#### Définition des plages de valeurs (ranged) :
Le script définit un dictionnaire ranged spécifiant les plages de valeurs pour différentes caractéristiques, utilisé ultérieurement pour la colorimétrie des données sur le tableau de bord.

#### Exceptions pour les pays (LE et E) :
Certaines exceptions sont définies pour les pays dont l'ISO 2 ne correspond pas aux abréviations du dictionnaire créé dans prepa.R.

#### Définition de fonctions de génération de graphiques (generate_histogram, generate_map_team, generate_map) :
Le script définit plusieurs fonctions réactives qui génèrent des graphiques en fonction des sélections de l'utilisateur. Ces fonctions utilisent les données préalablement chargées et préparées pour produire des histogrammes et des cartes interactives.

#### Création de l'interface Shiny (ui) :
L'interface Shiny est définie en utilisant des éléments de la bibliothèque Shiny. Elle comporte deux rangées, chacune contenant deux colonnes, avec différents éléments tels que des sélecteurs de saison, des graphiques, et des titres informatifs.

#### Définition du serveur Shiny (server) :
Le serveur Shiny est défini avec des fonctions réactives qui spécifient le comportement de l'application en réponse aux actions de l'utilisateur. Ces fonctions réagissent aux changements dans les sélections de l'utilisateur et génèrent dynamiquement les graphiques correspondants.

#### Lancement de l'application Shiny :
La dernière ligne lance l'application Shiny avec l'interface définie (ui) et le serveur défini (server).

Ce fichier constitue la structure principale de l'application Shiny du projet League of Legends, reliant les données préparées aux éléments interactifs de l'interface utilisateur.

`install.R` : (+ en détails)
#### Installation du package remotes :
Le script commence par installer le package remotes à l'aide de la fonction install.packages. Ce package est utilisé pour faciliter l'installation des dépendances nécessaires à partir d'un fichier requirements.txt.

#### Installation des dépendances à partir de requirements.txt :
Ensuite, le script définit une fonction install_packages qui lit le fichier requirements.txt. Ce fichier contient la liste des packages nécessaires pour l'application Shiny. La fonction compare cette liste avec les packages déjà installés et installe les packages manquants en utilisant la fonction install.packages.

#### Appel de la fonction d'installation :
Enfin, le script appelle la fonction install_packages(), ce qui lance le processus d'installation des packages nécessaires. Si des packages sont manquants, ils seront téléchargés et installés automatiquement.

Ce script est essentiel pour garantir que toutes les dépendances requises sont installées correctement avant l'exécution de l'application Shiny. L'utilisation du fichier requirements.txt facilite la gestion des versions des packages et assure une installation cohérente, garantissant ainsi le bon fonctionnement de l'application.

### Modification ou Extension du Code

Si vous souhaitez modifier ou étendre le code, suivez ces étapes :

1. Pour modifier le code, rendez-vous dans le fichier correspondant au module que vous souhaitez ajuster.
2. Pour étendre le code, ajoutez de nouveaux fichiers ou modules selon les besoins.
3. N'oubliez pas de mettre à jour le fichier `requirements.txt` si de nouveaux packages sont nécessaires.
4. Suivez les commentaires dans le code pour comprendre le fonctionnement de chaque section.

N'hésitez pas à consulter la documentation de Shiny (https://shiny.rstudio.com/) pour des détails sur la création d'applications interactives avec R.

## Requirements.txt

Le fichier `requirements.txt` contient la liste des packages nécessaires. Installez-les en utilisant le fichier `install.R` avec la commande :

```bash
Rscript install.R