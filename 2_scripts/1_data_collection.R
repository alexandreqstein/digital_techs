#### Sase article - data collection
#### Sase article - data collection
#### Sase article - data collection

# Start: 09/05/2023
# Author: Alexandre Stein



#install.packages("basedosdados")

library(data.table)
library(basedosdados)


# Baixando dados da Base dos dados ----------------------------------------

basedosdados::set_billing_id("complexidade-sebrae")


anos <- c(#'2006', '2007', '2008', 
          '2009', '2010',
          '2011', '2012', '2013', '2014', '2015',
          '2016', '2017', '2018', '2019', '2020', '2021')


estados <- c('AC', 'RR', 'RO', 'AM', 'PA', 'AP', 'TO', 'MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA',
             'MG', 'ES', 'RJ', 'SP', 'PR', 'SC', 'RS', 'MS', 'MT', 'GO', 'DF')


for (i in seq_along(anos))
    for (j in seq_along(estados)){
        
        quest <- paste("SELECT ano, sigla_uf, id_municipio, vinculo_ativo_3112, cbo_2002, cnae_2_subclasse, count(vinculo_ativo_3112) as qtd_vinc FROM `basedosdados.br_me_rais.microdados_vinculos` WHERE ano = ", 
                       anos[i], 
                       " AND sigla_uf = ",
                       "'",
                       estados[j],
                       "' AND vinculo_ativo_3112 = 1 ",
                       " GROUP BY ano, sigla_uf, id_municipio, vinculo_ativo_3112, cbo_2002, cnae_2_subclasse", 
                       sep = "")
        
        
        arquivo <- paste("C:/backup_arquivos/RAIS/dados_rais_cbo__cnae_06_2021/",
                         estados[j], "_", anos[i], ".csv", sep = "")
        
        
        basedosdados::download(query = quest, path = arquivo)
        
    }


# Transformando em RDS ----------------------------------------------------


library(data.table)
library(foreach)
library(doParallel)

setwd("C:/backup_arquivos/RAIS/dados_rais_cbo__cnae_06_2021")



# Defining paralellization ----------------------------------------------------

# Define number of clusters
parallel::detectCores()
n.cores <- parallel::detectCores() - 8

# Make a cluster
my.cluster <- parallel::makeCluster(
    n.cores, 
    type = "PSOCK"
)


print(my.cluster)

# Registering cluster
doParallel::registerDoParallel(cl = my.cluster)


# Checking 
foreach::getDoParRegistered()
foreach::getDoParWorkers()




files <- list.files(pattern = ".csv")

foreach (i = seq_along(files)) %dopar% {
    
    library(tidyverse)
    library(data.table)
    
    df <- fread(files[i], 
                colClasses = c(id_municipio = "character",
                               cbo_2002 = "character",
                               cnae_2_subclasse = "Character"))
    
    saveRDS(df, paste0(substr(files[i], 1, 7), ".RDS"))

    }

parallel::stopCluster(cl = my.cluster)


files <- list.files(pattern = ".RDS")

# Testanto se as CBOS estão ok

for(i in files){
    
    teste <- readRDS(i)
    
    if (min(nchar(teste$cbo_2002)) < 6 & min(nchar(teste$cbo_2002)) > 0 | is.na(min(nchar(teste$cbo_2002)))){
        
        print(file[i])
    } else {
        print("no")
    }
    
}






