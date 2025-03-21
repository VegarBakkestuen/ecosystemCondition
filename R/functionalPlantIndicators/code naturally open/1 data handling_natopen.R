library(downloader)
library(sf)
library(tidyr)
library(plyr)
library(dplyr)
library(stringr)
library(tidyverse)
library(readxl)
library(tmap)
library(tmaptools)

#### download from kartkatalogen to P-drive ####
# url <- "https://nedlasting.miljodirektoratet.no/naturovervaking/naturovervaking_eksport.gdb.zip"
#download(url, dest="P:/41201785_okologisk_tilstand_2022_2023/data/naturovervaking_eksport.gdb.zip", mode="w") 
#unzip ("P:/41201785_okologisk_tilstand_2022_2023/data/naturovervaking_eksport.gdb.zip", 
#       exdir = "P:/41201785_okologisk_tilstand_2022_2023/data/naturovervaking_eksport.gdb2")

#st_layers(dsn = "P:/41201785_okologisk_tilstand_2022_2023/data/naturovervaking_eksport.gdb2")

# SOMETHING NOT WORKING YET



#### upload data from P-drive ####
## ANO
#st_layers(dsn = "P:/41201785_okologisk_tilstand_2022_2023/data/Naturovervaking_eksport.gdb")
#ANO.sp <- st_read("P:/41201785_okologisk_tilstand_2022_2023/data/Naturovervaking_eksport.gdb",
#                  layer="ANO_Art")
#ANO.geo <- st_read("P:/41201785_okologisk_tilstand_2022_2023/data/Naturovervaking_eksport.gdb",
#                   layer="ANO_SurveyPoint")

# load from cache
ANO.sp<-readRDS(paste0(here::here(),"/data/cache/ANO.sp.RDS"))
ANO.geo<-readRDS(paste0(here::here(),"/data/cache/ANO.geo.RDS"))

head(ANO.sp)
head(ANO.geo)

## GRUK
#excel_sheets("P:/41201785_okologisk_tilstand_2022_2023/data/GRUK/GRUKdata_2020-2022_GJELDENDE.xlsx")
#GRUK.variables <- read_excel("P:/41201785_okologisk_tilstand_2022_2023/data/GRUK/GRUKdata_2020-2022_GJELDENDE.xlsx", 
#                             sheet = 2)
#GRUK.species <- read_excel("P:/41201785_okologisk_tilstand_2022_2023/data/GRUK/GRUKdata_2020-2022_GJELDENDE.xlsx", 
#                           sheet = 3)

# condition evaluation for 2021 data
#excel_sheets("P:/41201785_okologisk_tilstand_2022_2023/data/GRUK/NNF_GRUK_GJELDENDE.xls")

#GRUK2021.condition <- read_excel("P:/41201785_okologisk_tilstand_2022_2023/data/GRUK/NNF_GRUK_GJELDENDE.xls", 
#                                 sheet = 1)

# save to cache
#saveRDS(GRUK.variables, "data/cache/GRUK.variables.RDS")
#saveRDS(GRUK.species, "data/cache/GRUK.species.RDS")
#saveRDS(GRUK2021.condition, "data/cache/GRUK2021.condition.RDS")

# load from cache
GRUK.variables<-readRDS(paste0(here::here(),"/data/cache/GRUK.variables.RDS"))
GRUK.species<-readRDS(paste0(here::here(),"/data/cache/GRUK.species.RDS"))
GRUK2021.condition<-readRDS(paste0(here::here(),"/data/cache/GRUK2021.condition.RDS"))

head(GRUK.variables)
head(GRUK.species)
head(GRUK2021.condition)


## Tyler indicator data
#ind.Tyler <- read.table("P:/41201785_okologisk_tilstand_2022_2023/data/functional plant indicators/Tyler et al_Swedish plant indicators.txt",
#                        sep = '\t', header=T, quote = '')

ind.Tyler<-readRDS(paste0(here::here(),"/data/cache/ind.Tyler.RDS"))

head(ind.Tyler)

## Grime CSR-values
#ind.Grime <- read.csv("P:/41201785_okologisk_tilstand_2022_2023/data/functional plant indicators/Grime CSR.csv",sep=";",dec=",", header=T)

#saveRDS(ind.Grime, "data/cache/ind.Grime.RDS")

ind.Grime<-readRDS(paste0(here::here(),"/data/cache/ind.Grime.RDS"))
head(ind.Grime)

## generalized species lists NiN
#T2_ref <- read.csv("P:/41201785_okologisk_tilstand_2022_2023/data/functional plant indicators/reference from NiN/T2_ref.csv",sep=";", header=T)
#head(T2_ref)

#natopen_NiN_ref <- read_excel("P:/41201785_okologisk_tilstand_2022_2023/data/functional plant indicators/reference from NiN/Masterfil_artslister_organisert.xlsx", 
#                             sheet = 1)
#natopen_NiN_ref_spInfo <- read_excel("P:/41201785_okologisk_tilstand_2022_2023/data/functional plant indicators/reference from NiN/Masterfil_artslister_organisert.xlsx", 
#                              sheet = 2)

# save to cache
#saveRDS(natopen_NiN_ref, "data/cache/natopen_NiN_ref.RDS")
#saveRDS(natopen_NiN_ref_spInfo, "data/cache/natopen_NiN_ref_spInfo.RDS")

# load from cache
natopen_NiN_ref<-readRDS(paste0(here::here(),"/data/cache/natopen_NiN_ref.RDS"))
natopen_NiN_ref_spInfo<-readRDS(paste0(here::here(),"/data/cache/natopen_NiN_ref_spInfo.RDS"))

head(natopen_NiN_ref)
head(natopen_NiN_ref_spInfo)

#### data handling - functional indicator data ####
# trimming away sub-species & co, and descriptor info
ind.Grime[,'species.orig'] <- ind.Grime[,'species']
ind.Grime[,'species'] <- word(ind.Grime[,'species'], 1,2)
names(ind.Tyler)[1] <- 'species'
ind.Tyler$species <- as.factor(ind.Tyler$species)
summary(ind.Tyler$species)
ind.Tyler <- ind.Tyler[!is.na(ind.Tyler$species),]
ind.Tyler[,'species.orig'] <- ind.Tyler[,'species']
ind.Tyler[,'species'] <- word(ind.Tyler[,'species'], 1,2)

# dealing with 'duplicates'
ind.Grime[duplicated(ind.Grime[,'species']),"species"]
ind.Grime.dup <- ind.Grime[duplicated(ind.Grime[,'species']),c("species")]
ind.Grime[ind.Grime$species %in% ind.Grime.dup,]
# getting rid of the duplicates
ind.Grime <- ind.Grime %>% filter( !(species.orig %in% list("Carex viridula brachyrrhyncha",
                                                            "Dactylorhiza fuchsii praetermissa",
                                                            "Medicago sativa varia",
                                                            "Montia fontana chondrosperma",
                                                            "Papaver dubium lecoqii",
                                                            "Sanguisorba minor muricata")
) )
ind.Grime[duplicated(ind.Grime[,'species']),"species"]



names(ind.Tyler)[1] <- 'species'
ind.Tyler$species <- as.factor(ind.Tyler$species)
summary(ind.Tyler$species)
ind.Tyler <- ind.Tyler[!is.na(ind.Tyler$species),]
ind.Tyler[,'species.orig'] <- ind.Tyler[,'species']
ind.Tyler[,'species'] <- word(ind.Tyler[,'species'], 1,2)
#ind.Tyler2 <- ind.Tyler
#ind.Tyler <- ind.Tyler2
ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler.dup <- ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler[ind.Tyler$species %in% ind.Tyler.dup,c("Light","Moisture","Soil_reaction_pH","Nitrogen","species.orig","species")]
ind.Tyler <- ind.Tyler %>% filter( !(species.orig %in% list("Ammophila arenaria x Calamagrostis epigejos",
                                                            "Anemone nemorosa x ranunculoides",
                                                            "Armeria maritima ssp. elongata",
                                                            "Asplenium trichomanes ssp. quadrivalens",
                                                            "Calystegia sepium ssp. spectabilis",
                                                            "Campanula glomerata 'Superba'",
                                                            "Dactylorhiza maculata ssp. fuchsii",
                                                            "Erigeron acris ssp. droebachensis",
                                                            "Erigeron acris ssp. politus",
                                                            "Erysimum cheiranthoides L. ssp. alatum",
                                                            "Euphrasia nemorosa x stricta var. brevipila",
                                                            "Galium mollugo x verum",
                                                            "Geum rivale x urbanum",
                                                            "Hylotelephium telephium (ssp. maximum)",
                                                            "Juncus alpinoarticulatus ssp. rariflorus",
                                                            "Lamiastrum galeobdolon ssp. argentatum",
                                                            "Lathyrus latifolius ssp. heterophyllus",
                                                            "Medicago sativa ssp. falcata",
                                                            "Medicago sativa ssp. x varia",
                                                            "Monotropa hypopitys ssp. hypophegea",
                                                            "Ononis spinosa ssp. hircina",
                                                            "Ononis spinosa ssp. procurrens",
                                                            "Pilosella aurantiaca ssp. decolorans",
                                                            "Pilosella aurantiaca ssp. dimorpha",
                                                            "Pilosella cymosa ssp. gotlandica",
                                                            "Pilosella cymosa ssp. praealta",
                                                            "Pilosella officinarum ssp. peleteranum",
                                                            "Poa x jemtlandica (Almq.) K. Richt.",
                                                            "Poa x herjedalica Harry Sm.",
                                                            "Ranunculus peltatus ssp. baudotii",
                                                            "Sagittaria natans x sagittifolia",
                                                            "Salix repens ssp. rosmarinifolia",
                                                            "Stellaria nemorum L. ssp. montana",
                                                            "Trichophorum cespitosum ssp. germanicum")
) )
ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler.dup <- ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler[ind.Tyler$species %in% ind.Tyler.dup,c("Light","Moisture","Soil_reaction_pH","Nitrogen","species.orig","species")]
# getting rid of sect. for Hieracium
ind.Tyler <- ind.Tyler %>% mutate(species=gsub("sect. ","",species.orig))
ind.Tyler[,'species'] <- word(ind.Tyler[,'species'], 1,2)

ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler.dup <- ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]
ind.Tyler[ind.Tyler$species %in% ind.Tyler.dup,c("Light","Moisture","Soil_reaction_pH","Nitrogen","species.orig","species")]
# only hybrids left -> get rid of these
ind.Tyler <- ind.Tyler[!duplicated(ind.Tyler[,'species']),]
ind.Tyler[duplicated(ind.Tyler[,'species']),"species"]

ind.Tyler$species <- as.factor(ind.Tyler$species)
summary(ind.Tyler$species)
# no duplicates left

# merge indicator data
ind.dat <- merge(ind.Grime,ind.Tyler, by="species", all=T)
summary(ind.dat)
ind.dat[duplicated(ind.dat[,'species']),"species"]
ind.dat$species <- as.factor(ind.dat$species)
summary(ind.dat$species)
head(ind.dat)


#### data handling - ANO data ####
head(ANO.sp)
head(ANO.geo)

## fix NiN information
ANO.geo$hovedtype_rute <- substr(ANO.geo$kartleggingsenhet_1m2,1,3) # take the 3 first characters
ANO.geo$hovedtype_rute <- gsub("-", "", ANO.geo$hovedtype_rute) # remove hyphon
unique(as.factor(ANO.geo$hovedtype_rute))

## fix NiN-variables
colnames(ANO.geo)
colnames(ANO.geo)[42:47] <- c("groeftingsintensitet",
                              "bruksintensitet",
                              "beitetrykk",
                              "slatteintensitet",
                              "tungekjoretoy",
                              "slitasje")
head(ANO.geo)

# remove variable code in the data
ANO.geo$groeftingsintensitet <- gsub("7GR-GI_", "", ANO.geo$groeftingsintensitet) 
unique(ANO.geo$groeftingsintensitet)
ANO.geo$groeftingsintensitet <- gsub("X", "NA", ANO.geo$groeftingsintensitet)
unique(ANO.geo$groeftingsintensitet)
ANO.geo$groeftingsintensitet <- as.numeric(ANO.geo$groeftingsintensitet)
unique(ANO.geo$groeftingsintensitet)

ANO.geo$bruksintensitet <- gsub("7JB-BA_", "", ANO.geo$bruksintensitet) 
unique(ANO.geo$bruksintensitet)
ANO.geo$bruksintensitet <- gsub("X", "NA", ANO.geo$bruksintensitet)
unique(ANO.geo$bruksintensitet)
ANO.geo$bruksintensitet <- as.numeric(ANO.geo$bruksintensitet)
unique(ANO.geo$bruksintensitet)

ANO.geo$beitetrykk <- gsub("7JB-BT_", "", ANO.geo$beitetrykk) 
unique(ANO.geo$beitetrykk)
ANO.geo$beitetrykk <- gsub("X", "NA", ANO.geo$beitetrykk)
unique(ANO.geo$beitetrykk)
ANO.geo$beitetrykk <- as.numeric(ANO.geo$beitetrykk)
unique(ANO.geo$beitetrykk)

ANO.geo$slatteintensitet <- gsub("7JB-SI_", "", ANO.geo$slatteintensitet) 
unique(ANO.geo$slatteintensitet)
ANO.geo$slatteintensitet <- gsub("X", "NA", ANO.geo$slatteintensitet)
unique(ANO.geo$slatteintensitet)
ANO.geo$slatteintensitet <- as.numeric(ANO.geo$slatteintensitet)
unique(ANO.geo$slatteintensitet)

ANO.geo$tungekjoretoy <- gsub("7TK_", "", ANO.geo$tungekjoretoy) 
unique(ANO.geo$tungekjoretoy)
ANO.geo$tungekjoretoy <- gsub("X", "NA", ANO.geo$tungekjoretoy)
unique(ANO.geo$tungekjoretoy)
ANO.geo$tungekjoretoy <- as.numeric(ANO.geo$tungekjoretoy)
unique(ANO.geo$tungekjoretoy)

ANO.geo$slitasje <- gsub("7SE_", "", ANO.geo$slitasje) 
unique(ANO.geo$slitasje)
ANO.geo$slitasje <- gsub("X", "NA", ANO.geo$slitasje)
unique(ANO.geo$slitasje)
ANO.geo$slitasje <- as.numeric(ANO.geo$slitasje)
unique(ANO.geo$slitasje)

## check that every point is present only once
length(levels(as.factor(ANO.geo$ano_flate_id)))
length(levels(as.factor(ANO.geo$ano_punkt_id)))
summary(as.factor(ANO.geo$ano_punkt_id))
# there's many double presences, probably some wrong registrations of point numbers,
# CHECK THIS when preparing ecosystem-datasets for scaling




# fix species names
ANO.sp$Species <- ANO.sp$art_navn
unique(as.factor(ANO.sp$Species))
#ANO.sp$Species <- sub(".*?_", "", ANO.sp$Species) # lose the Norwegian name in the front
ANO.sp[,'Species'] <- word(ANO.sp[,'Species'], 1,2) # lose subspecies
ANO.sp$Species <- str_to_title(ANO.sp$Species) # make first letter capital
#ANO.sp$Species <- gsub("_", " ", ANO.sp$Species) # replace underscore with space
ANO.sp$Species <- gsub("( .*)","\\L\\1",ANO.sp$Species,perl=TRUE) # make capital letters after hyphon to lowercase
ANO.sp$Species <- gsub("( .*)","\\L\\1",ANO.sp$Species,perl=TRUE) # make capital letters after space to lowercase

## merge species data with indicators
ANO.sp.ind <- merge(x=ANO.sp[,c("Species", "art_dekning", "ParentGlobalID")], 
                    y= ind.dat[,c("species","CC", "SS", "RR","Light", "Nitrogen", "Soil_disturbance")],
                    by.x="Species", by.y="species", all.x=T)
summary(ANO.sp.ind)


# checking which species didn't find a match
unique(ANO.sp.ind[is.na(ANO.sp.ind$Light),'Species'])
#unique(ANO.sp.ind[!is.na(ANO.sp.ind$Light),'Species'])

ANO.sp.ind[ANO.sp.ind$Species=="Taraxacum officinale",]
ind.dat[ind.dat$species=="Picea sitchensis",]
ind.Grime[ind.Grime$species=="Picea sitchensis",]
ind.Tyler[ind.Tyler$species=="Picea sitchensis",]
ANO.sp[ANO.sp$Species=="Picea sitchensis",]

# fix species name issues
ind.dat <- ind.dat %>% 
  mutate(species=str_replace(species,"Aconitum lycoctonum", "Aconitum septentrionale")) %>% 
  mutate(species=str_replace(species,"Carex simpliciuscula", "Kobresia simpliciuscula")) %>%
  mutate(species=str_replace(species,"Carex myosuroides", "Kobresia myosuroides")) %>%
  mutate(species=str_replace(species,"Clinopodium acinos", "Acinos arvensis")) %>%
  mutate(species=str_replace(species,"Artemisia rupestris", "Artemisia norvegica")) %>%
  mutate(species=str_replace(species,"Cherleria biflora", "Minuartia biflora"))



ANO.sp <- ANO.sp %>% 
  mutate(Species=str_replace(Species,"Arctous alpinus", "Arctous alpina")) %>%
  mutate(Species=str_replace(Species,"Betula tortuosa", "Betula pubescens")) %>%
  mutate(Species=str_replace(Species,"Blysmopsis rufa", "Blysmus rufus")) %>%
  mutate(Species=str_replace(Species,"Cardamine nymanii", "Cardamine pratensis")) %>%
  mutate(Species=str_replace(Species,"Carex adelostoma", "Carex buxbaumii")) %>%
  mutate(Species=str_replace(Species,"Carex leersii", "Carex echinata")) %>%
  mutate(Species=str_replace(Species,"Carex paupercula", "Carex magellanica")) %>%
  mutate(Species=str_replace(Species,"Carex simpliciuscula", "Kobresia simpliciuscula")) %>%
  mutate(Species=str_replace(Species,"Carex viridula", "Carex flava")) %>%
  mutate(Species=str_replace(Species,"Chamaepericlymenum suecicum", "Cornus suecia")) %>%
  mutate(Species=str_replace(Species,"Cicerbita alpina", "Lactuca alpina")) %>%
  mutate(Species=str_replace(Species,"Empetrum hermaphroditum", "Empetrum nigrum")) %>%
  mutate(Species=str_replace(Species,"Festuca prolifera", "Festuca rubra")) %>%
  mutate(Species=str_replace(Species,"Galium album", "Galium mollugo")) %>%
  mutate(Species=str_replace(Species,"Galium elongatum", "Galium palustre")) %>%
  mutate(Species=str_replace(Species,"Helictotrichon pratense", "Avenula pratensis")) %>%
  mutate(Species=str_replace(Species,"Helictotrichon pubescens", "Avenula pubescens")) %>%
  mutate(Species=str_replace(Species,"Hieracium alpina", "Hieracium Alpina")) %>%
  mutate(Species=str_replace(Species,"Hieracium alpinum", "Hieracium Alpina")) %>%
  mutate(Species=str_replace(Species,"Hieracium hieracium", "Hieracium Hieracium")) %>%
  mutate(Species=str_replace(Species,"Hieracium hieracioides", "Hieracium umbellatum")) %>%
  mutate(Species=str_replace(Species,"Hieracium murorum", "Hieracium Vulgata")) %>%
  mutate(Species=str_replace(Species,"Hieracium oreadea", "Hieracium Oreadea")) %>%
  mutate(Species=str_replace(Species,"Hieracium prenanthoidea", "Hieracium Prenanthoidea")) %>%
  mutate(Species=str_replace(Species,"Hieracium vulgata", "Hieracium Vulgata")) %>%
  mutate(Species=str_replace(Species,"Hieracium pilosella", "Pilosella officinarum")) %>%
  mutate(Species=str_replace(Species,"Hieracium vulgatum", "Hieracium umbellatum")) %>%
  mutate(Species=str_replace(Species,"Hierochloã« alpina", "Hierochloë alpina")) %>%
  mutate(Species=str_replace(Species,"Hierochloã« hirta", "Hierochloë hirta")) %>%
  mutate(Species=str_replace(Species,"Hierochloã« odorata", "Hierochloë odorata")) %>%
  mutate(Species=str_replace(Species,"Listera cordata", "Neottia cordata")) %>%
  mutate(Species=str_replace(Species,"Leontodon autumnalis", "Scorzoneroides autumnalis")) %>%
  mutate(Species=str_replace(Species,"Loiseleuria procumbens", "Kalmia procumbens")) %>%
  mutate(Species=str_replace(Species,"Mycelis muralis", "Lactuca muralis")) %>%
  mutate(Species=str_replace(Species,"Omalotheca supina", "Gnaphalium supinum")) %>%
  mutate(Species=str_replace(Species,"Omalotheca norvegica", "Gnaphalium norvegicum")) %>%
  mutate(Species=str_replace(Species,"Omalotheca sylvatica", "Gnaphalium sylvaticum")) %>%
  mutate(Species=str_replace(Species,"Oreopteris limbosperma", "Thelypteris limbosperma")) %>%
  mutate(Species=str_replace(Species,"Oxycoccus microcarpus", "Vaccinium microcarpum")) %>%
  mutate(Species=str_replace(Species,"Oxycoccus palustris", "Vaccinium oxycoccos")) %>%
  mutate(Species=str_replace(Species,"Phalaris minor", "Phalaris arundinacea")) %>%
  mutate(Species=str_replace(Species,"Pinus unicinata", "Pinus mugo")) %>%
  mutate(Species=str_replace(Species,"Poa alpigena", "Poa pratensis")) %>%
  mutate(Species=str_replace(Species,"Poa angustifolia", "Poa pratensis")) %>%
  mutate(Species=str_replace(Species,"Pyrola grandiflora", "Pyrola rotundifolia")) %>%
  mutate(Species=str_replace(Species,"Rumex alpestris", "Rumex acetosa")) %>%
  mutate(Species=str_replace(Species,"Syringa emodi", "Syringa vulgaris")) %>%
  mutate(Species=str_replace(Species,"Taraxacum crocea", "Taraxacum officinale")) %>%
  mutate(Species=str_replace(Species,"Taraxacum croceum", "Taraxacum officinale")) %>%
  mutate(Species=str_replace(Species,"Trientalis europaea", "Lysimachia europaea")) %>%
  mutate(Species=str_replace(Species,"Trifolium pallidum", "Trifolium pratense"))

## merge species data with indicators
ANO.sp.ind <- merge(x=ANO.sp[,c("Species", "art_dekning", "ParentGlobalID")], 
                    y= ind.dat[,c("species","CC", "SS", "RR","Light", "Nitrogen", "Soil_disturbance")],
                    by.x="Species", by.y="species", all.x=T)
summary(ANO.sp.ind)
# checking which species didn't find a match
unique(ANO.sp.ind[is.na(ANO.sp.ind$Light),'Species'])
# don't find synonyms for these in the ind lists

## adding information on ecosystem and condition variables
ANO.sp.ind <- merge(x=ANO.sp.ind, 
                    y=ANO.geo[,c("GlobalID","ano_flate_id","ano_punkt_id","ssb_id","aar",
                                 "hovedoekosystem_punkt","hovedtype_rute","kartleggingsenhet_1m2",
                                 "vedplanter_total_dekning","busker_dekning","tresjikt_dekning","roesslyng_dekning")], 
                    by.x="ParentGlobalID", by.y="GlobalID", all.x=T)
# trimming away the points without information on NiN, species or cover
ANO.sp.ind <- ANO.sp.ind[!is.na(ANO.sp.ind$Species),]
ANO.sp.ind <- ANO.sp.ind[!is.na(ANO.sp.ind$art_dekning),]

#rm(ANO.sp)

#ANO.sp <- ANO.sp[!is.na(ANO.sp$Hovedoekosystem_rute),] # need to check
unique(as.factor(ANO.sp.ind$hovedoekosystem_punkt))
unique(as.factor(ANO.sp.ind$hovedtype_rute))
unique(as.factor(ANO.sp.ind$kartleggingsenhet_1m2))

summary(ANO.sp.ind)
head(ANO.sp.ind)




#### data handling - GRUK data ####
names(GRUK.variables)
names(GRUK.species)
names(GRUK2021.condition)

colnames(GRUK.species)[5] <- "art_dekning"

# fix species names
GRUK.species <- as.data.frame(GRUK.species)

GRUK.species$Species <- GRUK.species$Navn
unique(as.factor(GRUK.species$Species))
GRUK.species$Species <- sub(".*?_", "", GRUK.species$Species) # lose the Norwegian name in the front
GRUK.species$Species <- gsub("_", " ", GRUK.species$Species) # replace underscore with space
GRUK.species$Species <- str_to_title(GRUK.species$Species) # make first letter capital
GRUK.species$Species <- gsub("( .*)","\\L\\1",GRUK.species$Species,perl=TRUE) # make capital letters after hyphon to lowercase
GRUK.species$Species <- gsub("( .*)","\\L\\1",GRUK.species$Species,perl=TRUE) # make capital letters after space to lowercase
GRUK.species[,'Species'] <- word(GRUK.species[,'Species'], 1,2) # lose subspecies




## merge species data with indicators
GRUK.species.ind <- merge(x=GRUK.species[,c("Species", "art_dekning", "ParentGlobalID")], 
                          y= ind.dat[,c("species","CC", "SS", "RR","Light", "Nitrogen", "Soil_disturbance")],
                          by.x="Species", by.y="species", all.x=T)
summary(GRUK.species.ind)


# checking which species didn't find a match
unique(GRUK.species.ind[is.na(GRUK.species.ind$Light & 
                                is.na(GRUK.species.ind$RR)),'Species'])



# fix species name issues
ind.dat <- ind.dat %>% 
  #  mutate(species=str_replace(species,"Aconitum lycoctonum", "Aconitum septentrionale")) %>% 
  #  mutate(species=str_replace(species,"Carex simpliciuscula", "Kobresia simpliciuscula")) %>%
  #  mutate(species=str_replace(species,"Carex myosuroides", "Kobresia myosuroides")) %>%
  #  mutate(species=str_replace(species,"Clinopodium acinos", "Acinos arvensis")) %>%
  #  mutate(species=str_replace(species,"Artemisia rupestris", "Artemisia norvegica")) %>%
  mutate(species=str_replace(species,"Rosa vosagica", "Rosa vosagiaca"))



GRUK.species <- GRUK.species %>% 
  mutate(Species=str_replace(Species,"Arabis wahlenbergii", "Arabis hirsuta")) %>%
  #  mutate(Species=str_replace(Species,"Arctous alpinus", "Arctous alpina")) %>%
  #  mutate(Species=str_replace(Species,"Betula tortuosa", "Betula pubescens")) %>%
  #  mutate(Species=str_replace(Species,"Blysmopsis rufa", "Blysmus rufus")) %>%
  #  mutate(Species=str_replace(Species,"Cardamine nymanii", "Cardamine pratensis")) %>%
  #  mutate(Species=str_replace(Species,"Carex adelostoma", "Carex buxbaumii")) %>%
  #  mutate(Species=str_replace(Species,"Carex leersii", "Carex echinata")) %>%
  mutate(Species=str_replace(Species,"Carex paupercula", "Carex magellanica")) %>%
  #  mutate(Species=str_replace(Species,"Carex simpliciuscula", "Kobresia simpliciuscula")) %>%
  mutate(Species=str_replace(Species,"Carex viridula", "Carex flava")) %>%
  #  mutate(Species=str_replace(Species,"Chamaepericlymenum suecicum", "Cornus suecia")) %>%
  #  mutate(Species=str_replace(Species,"Cicerbita alpina", "Lactuca alpina")) %>%
  mutate(Species=str_replace(Species,"Cotoneaster scandinavicus", "Cotoneaster integerrimus")) %>%
  mutate(Species=str_replace(Species,"Cotoneaster symondsii", "Cotoneaster integrifolius")) %>%
  mutate(Species=str_replace(Species,"Cyanus montanus", "Centaurea montana")) %>%
  #  mutate(Species=str_replace(Species,"Empetrum hermaphroditum", "Empetrum nigrum")) %>%
  mutate(Species=str_replace(Species,"Erysimum virgatum", "Erysimum strictum")) %>%
  #  mutate(Species=str_replace(Species,"Festuca prolifera", "Festuca rubra")) %>%
  mutate(Species=str_replace(Species,"Festuca trachyphylla", "Festuca brevipila")) %>%
  mutate(Species=str_replace(Species,"Galium album", "Galium mollugo")) %>%
  #  mutate(Species=str_replace(Species,"Galium elongatum", "Galium palustre")) %>%
  mutate(Species=str_replace(Species,"Helictotrichon pratense", "Avenula pratensis")) %>%
  mutate(Species=str_replace(Species,"Helictotrichon pubescens", "Avenula pubescens")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium alpina", "Hieracium Alpina")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium alpinum", "Hieracium Alpina")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium hieracium", "Hieracium Hieracium")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium hieracioides", "Hieracium umbellatum")) %>%
  mutate(Species=str_replace(Species,"Hieracium murorum", "Hieracium Vulgata")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium oreadea", "Hieracium Oreadea")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium prenanthoidea", "Hieracium Prenanthoidea")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium vulgata", "Hieracium Vulgata")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium pilosella", "Pilosella officinarum")) %>%
  #  mutate(Species=str_replace(Species,"Hieracium vulgatum", "Hieracium umbellatum")) %>%
  #  mutate(Species=str_replace(Species,"Hierochloã« alpina", "Hierochloë alpina")) %>%
  #  mutate(Species=str_replace(Species,"Hierochloã« hirta", "Hierochloë hirta")) %>%
  #  mutate(Species=str_replace(Species,"Hierochloã« odorata", "Hierochloë odorata")) %>%
  mutate(Species=str_replace(Species,"Hylotelephium maximum", "Sedum telephium")) %>%
  #  mutate(Species=str_replace(Species,"Listera cordata", "Neottia cordata")) %>%
  #  mutate(Species=str_replace(Species,"Leontodon autumnalis", "Scorzoneroides autumnalis")) %>%
  mutate(Species=str_replace(Species,"Lepidotheca suaveolens", "Matricaria discoidea")) %>%
  #  mutate(Species=str_replace(Species,"Loiseleuria procumbens", "Kalmia procumbens")) %>%
  mutate(Species=str_replace(Species,"Malus ×domestica", "Malus domestica")) %>%
  #  mutate(Species=str_replace(Species,"Mycelis muralis", "Lactuca muralis")) %>%
  #  mutate(Species=str_replace(Species,"Omalotheca supina", "Gnaphalium supinum")) %>%
  #  mutate(Species=str_replace(Species,"Omalotheca norvegica", "Gnaphalium norvegicum")) %>%
  #  mutate(Species=str_replace(Species,"Omalotheca sylvatica", "Gnaphalium sylvaticum")) %>%
  #  mutate(Species=str_replace(Species,"Oreopteris limbosperma", "Thelypteris limbosperma")) %>%
  #  mutate(Species=str_replace(Species,"Oxycoccus microcarpus", "Vaccinium microcarpum")) %>%
  #  mutate(Species=str_replace(Species,"Oxycoccus palustris", "Vaccinium oxycoccos")) %>%
  #  mutate(Species=str_replace(Species,"Phalaris minor", "Phalaris arundinacea")) %>%
  #  mutate(Species=str_replace(Species,"Pinus unicinata", "Pinus mugo")) %>%
  #  mutate(Species=str_replace(Species,"Poa alpigena", "Poa pratensis")) %>%
  mutate(Species=str_replace(Species,"Poa angustifolia", "Poa pratensis")) %>%
  mutate(Species=str_replace(Species,"Poa humilis", "Poa pratensis")) %>%
  #  mutate(Species=str_replace(Species,"Pyrola grandiflora", "Pyrola rotundifolia")) %>%
  mutate(Species=str_replace(Species,"Rosa dumalis", "Rosa vosagiaca")) %>%
  #  mutate(Species=str_replace(Species,"Rumex alpestris", "Rumex acetosa")) %>%
  #  mutate(Species=str_replace(Species,"Syringa emodi", "Syringa vulgaris")) %>%
  #  mutate(Species=str_replace(Species,"Taraxacum crocea", "Taraxacum officinale")) %>%
  #  mutate(Species=str_replace(Species,"Taraxacum croceum", "Taraxacum officinale")) %>%
  #  mutate(Species=str_replace(Species,"Trientalis europaea", "Lysimachia europaea")) %>%
  mutate(Species=str_replace(Species,"Trifolium pallidum", "Trifolium pratense"))

## merge species data with indicators
GRUK.species.ind <- merge(x=GRUK.species[,c("Species", "art_dekning", "ParentGlobalID")], 
                          y= ind.dat[,c("species","CC", "SS", "RR","Light", "Nitrogen", "Soil_disturbance")],
                          by.x="Species", by.y="species", all.x=T)
summary(GRUK.species.ind)
# checking which species didn't find a match
unique(GRUK.species.ind[is.na(GRUK.species.ind$Light & 
                                is.na(GRUK.species.ind$RR)),'Species'])

### make GRUK.variables into spatial object
names(GRUK.variables)
GRUK.variables <- st_as_sf(GRUK.variables, coords = c("x","y"),remove=F)
# add CRS
GRUK.variables <- st_set_crs(GRUK.variables,4326)
# transform CRS to match ANO
GRUK.variables <- GRUK.variables %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(ANO.geo))

### merge GRUK.variables and GRUK2021.condition
#GRUK.variables <- as.data.frame(GRUK.variables)
GRUK2021.condition <- as.data.frame(GRUK2021.condition)

head(GRUK.variables)
head(GRUK2021.condition)

## fixing site-ID in the condition-data
GRUK2021.condition$Flate_ID <- GRUK2021.condition$områdenavn
unique(as.factor(GRUK2021.condition$Flate_ID))
GRUK2021.condition$Flate_ID <- gsub("_", " ", GRUK2021.condition$Flate_ID) # replace underscore with space
unique(as.factor(GRUK2021.condition$Flate_ID))
GRUK2021.condition$Flate_ID <- sub(" .*", "", GRUK2021.condition$Flate_ID) # remove everything after space
unique(as.factor(GRUK2021.condition$Flate_ID))

#GRUK2021.condition$Flate_ID <- gsub(" ", "-", GRUK2021.condition$Flate_ID) # replace space with hyphon
#GRUK2021.condition$Flate_ID <- gsub("[^0-9\\-]", "", GRUK2021.condition$Flate_ID) # remove all non-numerics except '-'
#GRUK2021.condition$Flate_ID <- gsub("--", "-", GRUK2021.condition$Flate_ID) # remove double hyphons
#GRUK2021.condition$Flate_ID <- substr(GRUK2021.condition$Flate_ID, 1, nchar(GRUK2021.condition$Flate_ID)-1) # remove the last character ('-' for all)


colnames(GRUK.variables)
colnames(GRUK2021.condition)

GRUK.variables <- merge(x=GRUK.variables, 
                        y=GRUK2021.condition[,c("tilstandsvurdering","tilstandsgrunn","artsmangfoldvurdering","lokalitetskvalitet","Flate_ID")], 
                        by.x="Flate_ID", by.y="Flate_ID", all.x=T)



## adding information on ecosystem and condition variables to species data
GRUK.species.ind <- merge(x=GRUK.species.ind, 
                          y=GRUK.variables[,c("GlobalID","year","Flate_ID","Punkt_ID",
                                              "Total dekning % av karplanter registert","Dekning % av karplanter i feltsjikt","Dekning % av moser",
                                              "Dekning % av lav","Dekning % av strø","Dekning % av bar jord/grus/stein/berg",
                                              "Kartleggingsenhet",
                                              "Spor etter ferdsel med tunge kjøretøy (%)","Spor etter slitasje og slitasjebetinget erosjon (%)","Dekning % av nakent berg","Menneskeskapte objekter i sirkelen?",
                                              "Total dekning % av vedplanter i feltsjikt","Dekning % av busker i busksjikt","Dekning % av tresjikt","Dekning % av problemarter","Total dekning % av fremmede arter",
                                              "x","y")], 
                          by.x="ParentGlobalID", by.y="GlobalID", all.x=T)
# trimming away the points without information on NiN, species or cover
GRUK.species.ind <- GRUK.species.ind[!is.na(GRUK.species.ind$Species),]
GRUK.species.ind <- GRUK.species.ind[!is.na(GRUK.species.ind$art_dekning),]

#rm(GRUK.species)
#rm(GRUK.variables)


summary(GRUK.species.ind)
head(GRUK.species.ind)








#### data handling - reference data, T2 only ####
head(T2_ref)

T2_ref.sp <- T2_ref %>%
  filter(artstype=="b") %>%
  select(KE2,speciesname,abun) %>%
  pivot_wider(names_from = KE2, values_from = abun, values_fill = 0)

colnames(T2_ref.sp)[1] <- "sp"
head(T2_ref.sp)

# merging with indicator values
# only genus and species name
T2_ref.sp$speciesname <- word(T2_ref.sp$sp, 1,2)
NiN.natopen <- merge(T2_ref.sp,ind.dat[,c(1,3:5,20,23,27)], by.x="sp", by.y="species", all.x=T)
head(NiN.natopen)
summary(NiN.natopen)




unique(NiN.natopen$sp)
#NiN.sp$spgr <- as.factor(as.vector(Eco_State$Concept_Data$Species$Species_List$art.code))

# checking which species didn't find a match
unique(NiN.natopen[is.na(NiN.natopen$Light) & is.na(NiN.natopen$Nitrogen) & is.na(NiN.natopen$RR),'sp'])

# fix species name issues
T2_ref.sp <- T2_ref.sp %>% 
  mutate(sp=str_replace(sp,"Berberis vulgars", "Berberis vulgaris")) %>% 
  mutate(sp=str_replace(sp,"Cirsium acaulon", "Cirsium acaule")) %>%
  mutate(sp=str_replace(sp,"Erigeron acris ssp. droebachiensis", "Erigeron acris")) %>%
  mutate(sp=str_replace(sp,"Erigeron acris subsp. droebachiensis", "Erigeron acris")) %>%
  mutate(sp=str_replace(sp,"Euphrasia aff. salisburgensis", "Euphrasia salisburgensis")) %>%
  mutate(sp=str_replace(sp,"Hylotelephium maximum", "Hylotelephium telephium")) %>%
  mutate(sp=str_replace(sp,"Phleum pratense subsp. nodosum", "Phleum pratense")) %>%
  mutate(sp=str_replace(sp,"Poa alpina var. alpina", "Poa alpina")) %>%
  mutate(sp=str_replace(sp,"Thymus serpyllum ssp. serpyllum", "Thymus serpyllum")) %>%
  mutate(sp=str_replace(sp,"Thymus serpyllum subsp. serpyllum", "Thymus serpyllum"))

ind.dat[2556,'species'] <- "Saxifraga osloensis"


# merging with indicator values
NiN.natopen <- merge(T2_ref.sp,ind.dat[,c(1,3:5,20,23,27)], by.x="sp", by.y="species", all.x=T)
# checking which species didn't find a match
unique(NiN.natopen[is.na(NiN.natopen$Light) & is.na(NiN.natopen$Nitrogen & is.na(NiN.natopen$RR)),'sp'])
# ok now


# translating the abundance classes into %-cover
coverscale <- data.frame(orig=0:6,
                         cov=c(0, 1/32 ,1/8, 3/8, 0.6, 4/5, 1)
)

NiN.natopen.cov <- NiN.natopen
colnames(NiN.natopen.cov)
for (i in 2:11) {
  NiN.natopen.cov[,i] <- coverscale[,2][ match(NiN.natopen[,i], 0:6 ) ]
}

summary(NiN.natopen)
summary(NiN.natopen.cov)



#### data handling - reference data, all natopen types ####
head(natopen_NiN_ref)
head(natopen_NiN_ref_spInfo)

colnames(natopen_NiN_ref)[1] <- "sp"
head(natopen_NiN_ref)

natopen_NiN_ref <- merge(natopen_NiN_ref,natopen_NiN_ref_spInfo[,c(1,4)], by.x="sp", by.y="ScientificName", all.x=T)
unique(natopen_NiN_ref[is.na(natopen_NiN_ref$Phylum),'sp']) # Pucinella does not exist in ind.dat, so we don't care
# we're only interested in vascular plants and ferns, which we have indicators on
unique(natopen_NiN_ref$Phylum)
natopen_NiN_ref <- natopen_NiN_ref %>%
  filter(Phylum %in% c("Magnoliophyta","Pteridophyta"))
unique(natopen_NiN_ref$Phylum)



natopen_NiN_ref$sp
# only genus and species name
natopen_NiN_ref$sp.orig <- natopen_NiN_ref$sp
natopen_NiN_ref$sp <- word(natopen_NiN_ref$sp, 1,2)
natopen_NiN_ref <- natopen_NiN_ref[!is.na(natopen_NiN_ref$sp),]
# merging with indicator values
NiN.natopen <- merge(natopen_NiN_ref,ind.dat[,c(1,3:5,20,23,27)], by.x="sp", by.y="species", all.x=T)
head(NiN.natopen)
summary(NiN.natopen)



NiN.natopen
unique(NiN.natopen$sp)
#NiN.sp$spgr <- as.factor(as.vector(Eco_State$Concept_Data$Species$Species_List$art.code))

# checking which species didn't find a match
unique(NiN.natopen[is.na(NiN.natopen$Light) & is.na(NiN.natopen$Nitrogen) & is.na(NiN.natopen$RR),'sp'])

# fix species name issues
natopen_NiN_ref <- natopen_NiN_ref %>% 
  mutate(sp=str_replace(sp,"Cirsium acaulon", "Cirsium acaule")) %>%
  mutate(sp=str_replace(sp,"Hylotelephium maximum", "Hylotelephium telephium"))

ind.dat[2556,'species'] <- "Saxifraga osloënsis"
ind.dat[17,'species'] <- "Hierochloë odorata"
ind.dat[9,'species'] <- "Hippophaë rhamnoides"


# merging with indicator values
NiN.natopen <- merge(natopen_NiN_ref,ind.dat[,c(1,3:5,20,23,27)], by.x="sp", by.y="species", all.x=T)
# checking which species didn't find a match
unique(NiN.natopen[is.na(NiN.natopen$Light) & is.na(NiN.natopen$Nitrogen) & is.na(NiN.natopen$RR),'sp'])
# ok now


# translating the abundance classes into %-cover
coverscale <- data.frame(orig=0:6,
                         cov=c(0, 1/32 ,1/8, 3/8, 0.6, 4/5, 1)
)

NiN.natopen.cov <- NiN.natopen
colnames(NiN.natopen.cov)
for (i in 2:71) {
  NiN.natopen.cov[,i] <- coverscale[,2][ match(NiN.natopen[,i], 0:6 ) ]
}

summary(NiN.natopen)
summary(NiN.natopen.cov)




save.image("P:/41201785_okologisk_tilstand_2022_2023/data/FPI_output large files for markdown/data_natopen.RData")

load("P:/41201785_okologisk_tilstand_2022_2023/data/FPI_output large files for markdown/data_natopen.RData")

#### continue here ####
