mergedata = function(track = "track2") {
  # make sure the working directory is "track2"
  require(doMC)  # parallel merging
  registerDoMC(detectCores())
  practice_files = list.files(paste0(track,"/","practice"), pattern="*.csv", full.names=TRUE)
  practice_year_files = list.files(paste0(track,"/","practice_year"), pattern="*.csv", full.names=TRUE)
  mergedata = foreach(i=1:3400) %dopar% {
    practice = read.csv(practice_files[i])
    practice_year = read.csv(practice_year_files[i])
    dplyr::full_join(practice, practice_year, by = "id.practice")
  }
  return(mergedata)
}
merged = mergedata()
saveRDS(merged, file = "merged_datasets.rds")
