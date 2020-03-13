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

### tab_jour = evolution nationale quotidienne
# changer les noms des colonnes (elles sont toutes identiques????)
# ajouter les dates manquantes (5 fév -> 14 fév et 16 fév -> 29 fév)
# ne garder que le nombre de malade dans une deuxième colonne
# au final une ligne devrait juste être date + nombre de malades (pas possible de séparer les guérisons avec ce tableau)


# Je garde les colonnes d'intérêt et vire la première ligne en R de base
tab_jour[-1, c(1,4)] -> tj
# Je renomme mes colonnes en R de base
names(tj) <- c("date", "cas")
# Je filtre les lignes "------" avec tidyverse
tj <- filter(tj, date != "----------") 
# J'utilise une expression régulière pour ne garder dans la colonne cas 
# uniquement les chaines de caractères qui débute (^) par des chiffres (\d*)
# et je transforme le tout en valeur numérique 
tj <- mutate(tj, cas = as.numeric(stringr::str_extract(cas, pattern = "^\\d*")))

# Je transforme la colonne date pour avoir un format date utilisable dans R
tj <- mutate(tj, date = lubridate::dmy(date))

chart(tj, cas ~ date) +
  geom_point() + 
  geom_line() +
  labs(y = "Nombre de cas", x = "Date")

write$csv(tj, file = "data/Tableau_jour.csv")

### tab_geo = nombre de malade par subdivision geographique (Region, provinces, communes) 
# Retirer les lignes inutiles
# Filtrer la colonne ville
# Séparer la colonne province et le nombre de malades  

tab_geo <- select(tab_geo, Régions, Provinces)
tab_geo <- filter(tab_geo, Provinces != "Région flamande", Provinces != "Région wallonne", Provinces != "—")
tab_geo <- unique(tab_geo)


tab_geo <- separate(tab_geo, col = "Provinces", into = c("Provinces", "Malades"), sep = ": ")
tab_geo$Malades <- as.numeric(tab_geo$Malades)

tab_geo <- filter(tab_geo, 
  !stringr::str_detect(Provinces, "^Tot") | stringr::str_detect(Régions, "Capitale$"))

#tab_geo[!grepl("Total", tab_geo$Provinces[tab_geo$Régions != "Région de Bruxelles-Capitale"]), ] -> tab_geo
#Pour une raison quelconque, cette ligne ne fonctionne. Elle est sensé supprimer toutes les lignes avec "Total" dans la colonne "Provinces" sauf si "Régions" est Bruxelles capitale. Sauf que non seulement la dernière ligne (total) est toujours là, mais elle supprime "Région wallonne/Lieux inconnus". J'ai essayé plusieurs méthodes différentes sans aucun succès (comme filter, ou même subset).

write$csv(tab_geo, file = "data/Tableau_geographique.csv")

# Une version fonctionnelle pour tab_geo
tab_geo <- tableau[[3]]

# changement des noms des colonnes
names(tab_geo) %>.%
  stringr::str_to_lower(.) %>.%
  stringi::stri_trans_general(.,id = "Latin-ASCII") -> names(tab_geo)

tab_geo %>.%
  as_tibble(.) %>.%
  select(., regions, provinces) %>.% # selection des régions et provinces
  filter(., !stringr::str_detect(provinces, "^Ré")) %>.% # retire de provinces tout ce qui commence par "Ré"
  mutate(., cas = as.numeric(stringr::str_extract(provinces, pattern = "\\d*$"))) %>.% # on calcule une nouvelles variables qui extrait de provinces, les derniers chiffres
  fill(., cas, .direction = "up") %>.% # on complete les valeurs manquantes de la colonne cas, par la valeur suivantes de la colonne cas
  filter(., !stringr::str_detect(provinces, "^To")) %>.% # on filtre tout ce qui commence par To dans la colonne province
  mutate(t, provinces = stringr::str_remove_all(provinces,pattern = "[:,\\d*$]")) -> tb # On retire de provinces tout ce qui se termine par ": et chiffres"


