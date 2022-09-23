pool::poolClose(con)

postgis$stop()

docker$container$remove(id = "postgis-ely")

rm(con, postgis, docker)
