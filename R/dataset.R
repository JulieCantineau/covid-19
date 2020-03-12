# acquisition des données 
# packages -----
SciViews::R()
library(rvest)

# Vu qu'il n'y a aucune base de données, je vais employer les données de wikipedia.
# Je suis cependant trop faineant pour tout recopier. # J'utilise donc rvest pour faire du webscraping
# https://thinkr.fr/rvest/
# https://rvest.tidyverse.org 

# extraction des tableau
tableau <- read_html("https://fr.wikipedia.org/wiki/Épidémie_de_maladie_à_coronavirus_de_2020_en_Belgique") %>%
  html_nodes("table") %>%
  html_table(fill = TRUE) 

# extraction du tableau d'interêt.
tab_jour <- tableau[[2]]  # evolution journalière
tab_geo <- tableau[[3]] # evolution par zone

# modification du tableau afin d'en faire un beau tableau cas par variable


# TODO
### tab_jour = evolution nationale quotidienne
# changer les noms des colonnes (elles sont toutes identiques????)
# ajouter les dates manquantes (5 fév -> 14 fév et 16 fév -> 29 fév)
# ne garder que le nombre de malade dans une deuxième colonne
# au final une ligne devrait juste être date + nombre de malades (pas possible de séparer les guérisons avec ce tableau)
# 
### tab_geo = nombre de malade par subdivision geographique (Region, provinces, communes) 
# Retirer les lignes inutiles
# Filtrer la colonne ville
# Séparer la colonne province et le nombre de malades  

tab_geo <- select(tab_geo, Régions, Provinces)
tab_geo <- filter(tab_geo, Provinces != "Région flamande", Provinces != "Région wallonne", Provinces != "—")
tab_geo <- unique(tab_geo)


tab_geo <- separate(tab_geo, col = "Provinces", into = c("Provinces", "Malades"), sep = ": ")
tab_geo$Malades <- as.numeric(tab_geo$Malades)
#tab_geo[!grepl("Total", tab_geo$Provinces[tab_geo$Régions != "Région de Bruxelles-Capitale"]), ] -> tab_geo
#Pour une raison quelconque, cette ligne ne fonctionne. Elle est sensé supprimer toutes les lignes avec "Total" dans la colonne "Provinces" sauf si "Régions" est Bruxelles capitale. Sauf que non seulement la dernière ligne (total) est toujours là, mais elle supprime "Région wallonne/Lieux inconnus". J'ai essayé plusieurs méthodes différentes sans aucun succès (comme filter, ou même subset).


write$csv(tab_geo, file = "data/Tableau_geographique.csv")
