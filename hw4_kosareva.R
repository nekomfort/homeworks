motifs2 <- matrix(c(
  "a", "C", "g", "G", "T", "A", "A", "t", "t", "C", "a", "G",
  "t", "G", "G", "G", "C", "A", "A", "T", "t", "C", "C", "a",
  "A", "C", "G", "t", "t", "A", "A", "t", "t", "C", "G", "G",
  "T", "G", "C", "G", "G", "G", "A", "t", "t", "C", "C", "C",
  "t", "C", "G", "a", "A", "A", "A", "t", "t", "C", "a", "G",
  "A", "C", "G", "G", "C", "G", "A", "a", "t", "T", "C", "C",
  "T", "C", "G", "t", "G", "A", "A", "t", "t", "a", "C", "G",
  "t", "C", "G", "G", "G", "A", "A", "t", "t", "C", "a", "C",
  "A", "G", "G", "G", "T", "A", "A", "t", "t", "C", "C", "G",
  "t", "C", "G", "G", "A", "A", "A", "a", "t", "C", "a", "C"
), nrow = 10, byrow = TRUE)

motifs2 <- toupper(motifs2)

count_matrix <- apply(motifs2, 2, function(col) table(factor(col, levels = c("A", "C", "G", "T"))))

profile_matrix <- apply(count_matrix, 2, function(x) {x / sum(x)})

scoreMotifs <- function(motif_matrix) {
  count_matrix <- apply(motif_matrix, 2, function(x) {
    table(factor(x, levels = c("A", "C", "G", "T")))})
  
  consensus <- apply(count_matrix, 2, function(x) {
    c("A", "C", "G", "T")[which.max(x)]})
  
  score <- 0
  for (i in 1:ncol(motif_matrix)) {
    score <- score + sum(motif_matrix[, i] != consensus[i])}
  
  return(score)

}

motif_score <- scoreMotifs(motifs2)


getConsensus <- function(motif_matrix) {
  count_matrix <- apply(motif_matrix, 2, function(x) {
    table(factor(x, levels = c("A", "C", "G", "T")))
  })
  
  consensus <- apply(count_matrix, 2, function(x) {
    c("A", "C", "G", "T")[which.max(x)]
  })
  
  return(paste(consensus, collapse = ""))
}

consensus_seq <- getConsensus(motifs2)

first_col_freq <- count_matrix[, 1] / sum(count_matrix[, 1])

barplot(first_col_freq, 
        col = "skyblue", 
        main = "Частоты нуклеотидов в первом столбце",
        xlab = "Нуклеотиды", 
        ylab = "Частота",
        ylim = c(0, 1))
