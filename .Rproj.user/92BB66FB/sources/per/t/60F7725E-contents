# # install.R
# # Installer les packages depuis requirements.txt
# 
# install.packages("remotes") 
# remotes::install_deps(dependencies = TRUE)
# 
# 
# install_packages <- function() { # Fonction : Vérifier et installer les packages manquants
#   required_packages <- readLines("requirements.txt")
#   
#   # Installer les packages manquants
#   missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
#   
#   if (length(missing_packages) > 0) {
#     install.packages(missing_packages, dependencies = TRUE)
#   }
# }
# 
# # Appel de la fonction pour installer les packages
# install_packages()

# install.R
# Installer les packages depuis requirements.txt

# Lire les noms des packages depuis requirements.txt
required_packages <- readLines("requirements.txt")

# Installer les packages manquants
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, dependencies = TRUE)
}

# Autres opérations d'installation, le cas échéant
# ...

# Vous n'avez pas besoin de la fonction install_packages() dans ce contexte
# ...

# Vous pouvez également ajouter un message pour indiquer que l'installation est terminée
cat("Installation des packages terminée.\n")
