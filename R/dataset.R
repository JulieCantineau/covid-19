# acquisition des données 
# packages -----
SciViews::R()
library(rvest)

# Vu qu'il n'y a aucune base de données, j'e vais employer les données de wikipedia.
# Je suis cependant trop feneant pour tout recopier. # J'utilise donc rvest pour faire du webscraping
# https://thinkr.fr/rvest/
# https://rvest.tidyverse.org 

# extraction des tableau
tableau <- read_html("https://fr.wikipedia.org/wiki/Épidémie_de_maladie_à_coronavirus_de_2020_en_Belgique") %>%
  html_nodes("table") %>%
  html_table(fill = TRUE) 

# extraction du tableau d'interêt.
tab <- tableau[[3]]

# modification du tableau afin d'en faire un beau tableau cas par variable

# TODO
