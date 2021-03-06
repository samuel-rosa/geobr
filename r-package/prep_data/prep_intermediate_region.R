#> DATASET: Intermediate Geographic Regions - 2019
#> Source: IBGE - https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?=&t=o-que-e
#> scale 1:250.000 ?????????????
#> Metadata:
# Titulo: Regioes Geograficas Intermediarias
# Titulo alternativo:
# Frequencia de atualizacao: decenal
#
# Forma de apresentacao: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Regioes Geograficas Intermediarias foram criadas pelo IBGE em 2017 para substituir a meso-regioes
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
# Informacao do Sistema de Referencia: SIRGAS 2000

### Libraries (use any library as necessary)

library(RCurl)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(data.table)
library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)
library(stringi)

####### Load Support functions to use in the preprocessing of the data -----------------
source("./prep_data/prep_functions.R")
source('./prep_data/download_malhas_municipais_function.R')


# If the data set is updated regularly, you should create a function that will have
# a `date` argument download the data

update <- 2020


# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./intermediate_regions")
setwd("./intermediate_regions")



# Create folders to save clean sf.rds files
destdir_clean <- paste0("./shapes_in_sf_cleaned/",update)
dir.create( destdir_clean , showWarnings = FALSE)



#### 0. Download original Intermediate Regions data sets from IBGE ftp -----------------

if(update == 2019){
  ftp <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2019/Brasil/BR/br_regioes_geograficas_intermediarias.zip'
  download.file(url = ftp, destfile = "RG2019_rgint_20190430.zip")
}

if(update == 2017){
  ftp <- 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/divisao_regional_do_brasil/divisao_regional_do_brasil_em_regioes_geograficas_2017/shp/RG2017_rgint_20180911.zip'
  download.file(url = ftp, destfile = "RG2017_rgint_20180911.zip")
}


########  1. Unzip original data sets downloaded from IBGE -----------------

if(update == 2019){
  unzip("RG2019_rgint_20190430.zip")
}

if(update == 2017){
  unzip("RG2017_rgint_20180911.zip")
}


###### Unzip raw data --------------------------------
unzip_to_geopackage(region='intermediaria', year=2020)



###### Cleaning UF files --------------------------------
setwd('L:/# DIRUR #/ASMEQ/geobr/data-raw/malhas_municipais')

# get folders with years
data_dir <-  paste0(getwd(),"./shapes_in_sf_all_years_original/intermediaria")
sub_dirs <- list.dirs(path =data_dir, recursive = F)
sub_dirs <- sub_dirs[sub_dirs %like% paste0(2000:2020,collapse = "|")]





##### 2. Rename columns -------------------------
#
# # read data
# if(update == 2019){
#   temp_sf <- st_read("BR_RG_Intermediarias_2019.shp", quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
#
#   temp_sf <- dplyr::rename(temp_sf, code_intermediate = CD_RGINT, name_intermediate = NM_RGINT)
# }
#
# if(update == 2017){
#   temp_sf <- st_read("RG2017_rgint.shp", quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")
#
#   temp_sf <- dplyr::rename(temp_sf, code_intermediate = rgint, name_intermediate = nome_rgint)
# }
#
# # reorder columns
# temp_sf <- dplyr::select(temp_sf, 'code_intermediate', 'name_intermediate','code_state', 'abbrev_state',
#                          'name_state', 'code_region', 'name_region', 'geometry')



# create a function that will clean the sf files according to particularities of the data in each year
clean_intermediate <- function( e , year){ #  e <- sub_dirs[ sub_dirs %like% 2020]

  # select year
  if (year == 'all') {
    message(paste('Processing all years'))
  } else{
    if (!any(e %like% year)) {
      return(NULL)
    }
  }

  message(paste('Processing',year))

  options(encoding = "UTF-8")

  # get year of the folder
  last4 <- function(x){substr(x, nchar(x)-3, nchar(x))}   # function to get the last 4 digits of a string
  year <- last4(e)
  year

  # create a subdirectory of years
  dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned2/intermediaria/",year)), showWarnings = FALSE, recursive = T)
  gc(reset = T)

  dir.dest <- file.path(paste0("./shapes_in_sf_all_years_cleaned2/intermediaria/",year))


  # list all sf files in that year/folder
  sf_files <- list.files(e, full.names = T, recursive = T, pattern = ".gpkg$")

  #sf_files <- sf_files[sf_files %like% "Microrregioes"]

  # for each file
  for (i in sf_files){ #  i <- sf_files[1]

    # read sf file
    temp_sf <- st_read(i)
    names(temp_sf) <- names(temp_sf) %>% tolower()
    head(temp_sf)


    if (year %like% "2020"){
      # dplyr::rename and subset columns
      temp_sf <- dplyr::select(temp_sf, c('code_intermediate'=cd_rgint,
                                          'name_intermediate'=nm_rgint,
                                          'abbrev_state'=sigla_uf,
                                          'geom'))
    }


    # add name_state
    temp_sf$code_state <- substring(temp_sf$code_intermediate, 1,2)
    temp_sf <- add_state_info(temp_sf,column = 'code_state')

    # Use UTF-8 encoding
    options(encoding = "UTF-8")
    temp_sf <- use_encoding_utf8(temp_sf)
    head(temp_sf)

    # reorder columns
    temp_sf <- dplyr::select(temp_sf, 'code_intermediate', 'name_intermediate', 'code_state', 'abbrev_state', 'name_state', 'geom')



    # remove Z dimension of spatial data
    temp_sf <- temp_sf %>% st_sf() %>% st_zm( drop = T, what = "ZM")
    head(temp_sf)

    # Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
    temp_sf <- harmonize_projection(temp_sf)


    # Make an invalid geometry valid # st_is_valid( sf)
    temp_sf <- sf::st_make_valid(temp_sf)


    # simplify
    temp_sf_simplified <- simplify_temp_sf(temp_sf)

    # convert to MULTIPOLYGON
    temp_sf <- to_multipolygon(temp_sf)
    temp_sf_simplified <- to_multipolygon(temp_sf_simplified)

    # Save cleaned sf in the cleaned directory
    dir.dest.file <- paste0(dir.dest,"/")
    file.name <- paste0("intermediate_regions_",year,".gpkg")

    # original
    i <- paste0(dir.dest.file,file.name)
    sf::st_write(temp_sf, i, overwrite=TRUE)

    # simplified
    i <- gsub(".gpkg", "_simplified.gpkg", i)
    sf::st_write(temp_sf_simplified, i, overwrite=TRUE)
  }
}



# apply function in parallel
future::plan(multisession)
future_map(.x=sub_dirs, .f=clean_intermediate, year=2020)

rm(list= ls())
gc(reset = T)

