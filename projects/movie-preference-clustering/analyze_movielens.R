# MovieLens 100K のクラスタリング再構成版 (R)
#
# 大学レポートに記載した方法から作り直した参考コード。
# 授業で実際に提出したソースではありません。
# 公式 MovieLens 100K から u.data と u.item を入手してください:
# https://grouplens.org/datasets/movielens/100k/
#
# 実行例: Rscript analyze_movielens.R /path/to/ml-100k
# R環境での動作確認・元レポートの数値との照合はまだしていません。
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) stop("使用方法: Rscript analyze_movielens.R /path/to/ml-100k")
data_dir <- args[[1]]
required_files <- file.path(data_dir, c("u.data", "u.item"))
if (!all(file.exists(required_files))) {
  stop("MovieLens 100K の u.data と u.item を指定ディレクトリに置いてください")
}
ratings <- read.table(file.path(data_dir, "u.data"), sep = "\t", header = FALSE,
                      col.names = c("user_id", "movie_id", "rating", "timestamp"))
genre_names <- c("unknown", "Action", "Adventure", "Animation", "Children",
                 "Comedy", "Crime", "Documentary", "Drama", "Fantasy",
                 "Film-Noir", "Horror", "Musical", "Mystery", "Romance",
                 "Sci-Fi", "Thriller", "War", "Western")
item_cols <- c("movie_id", "title", "release_date", "video_date", "imdb_url", genre_names)
items <- read.table(file.path(data_dir, "u.item"), sep = "|", header = FALSE,
                    fill = TRUE, quote = "", fileEncoding = "latin1",
                    col.names = item_cols, check.names = FALSE, comment.char = "", stringsAsFactors = FALSE)
genres <- c("Drama", "Comedy", "Action", "Thriller",
            "Romance", "Adventure", "Sci-Fi", "War")
ratings_all_mean <- aggregate(rating ~ user_id, ratings, mean)
names(ratings_all_mean)[2] <- "user_mean"
joined <- merge(ratings[, 1:3], items[, c("movie_id", genres)], by = "movie_id")
users <- sort(unique(joined$user_id))
genre_score <- matrix(NA_real_, length(users), length(genres),
                      dimnames = list(as.character(users), genres))
for (g in genres) {
  subset_g <- joined[joined[[g]] == 1, c("user_id", "rating")]
  means <- tapply(subset_g$rating, subset_g$user_id, mean)
  genre_score[names(means), g] <- means
}
keep <- complete.cases(genre_score)
X <- genre_score[keep, , drop = FALSE]
m <- ratings_all_mean$user_mean[match(as.integer(rownames(X)), ratings_all_mean$user_id)]
X_pref <- sweep(X, 1L, m, FUN = "-")
cat("分析対象の利用者数:", nrow(X_pref), "\n")
set.seed(123)
ward <- hclust(dist(X_pref, method = "euclidean"), method = "ward.D2")
ward_groups <- cutree(ward, k = 2L)
km <- kmeans(X_pref, centers = 2L, nstart = 30L)
# ラベルの入れ替わりを補正する。Sci-Fi嗜好の高い群を1とする
align_group <- function(group, data) {
  mean_sci <- tapply(data[, "Sci-Fi"], group, mean)
  high <- as.integer(names(which.max(mean_sci)))
  ifelse(group == high, 1L, 2L)
}
ward_label <- align_group(ward_groups, X_pref)
km_label <- align_group(km$cluster, X_pref)
cat("Wardの群人数:\n")
print(table(ward_label))
cat("k-meansの群人数:\n")
print(table(km_label))
cat("一致度:", round(mean(ward_label == km_label) * 100, 1), "%\n")
for (method in c("ward", "kmeans")) {
  labels <- if (method == "ward") ward_label else km_label
  cat("\n", method, " 群別平均:\n", sep = "")
  print(aggregate(as.data.frame(X_pref), list(group = labels), mean))
}
png("dendrogram.png", width = 1100, height = 700)
plot(ward, labels = FALSE, main = "MovieLens 100K : Ward dendrogram", xlab = "", sub = "")
dev.off()
cat("dendrogram.png を保存しました。\n")
