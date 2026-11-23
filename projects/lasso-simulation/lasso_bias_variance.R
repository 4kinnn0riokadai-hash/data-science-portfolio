# 計算機統計学AのLASSO課題をもとに整理した再実装
# 授業提出時のコードとは異なる修正版です。R環境での動作確認は未実施。
if (!requireNamespace("glmnet", quietly = TRUE)) {
  stop("glmnet が必要です: install.packages('glmnet')")
}
set.seed(123)
n <- 30L
p <- 10L
n_sim <- 1000L
beta_base <- c(3, 1.5, 0, 0, 2, rep(0, 5))

simulate_lasso <- function(beta_true, noise_sd = 1, n_sim = 1000L, n = 30L, p = 10L) {
  stopifnot(length(beta_true) == p, n >= 3, noise_sd > 0, n_sim > 1)
  results <- matrix(NA_real_, nrow = n_sim, ncol = p + 1L)
  for (i in seq_len(n_sim)) {
    X <- matrix(rnorm(n * p), nrow = n, ncol = p)
    y <- as.vector(X %*% beta_true + rnorm(n, sd = noise_sd))
    fit <- glmnet::cv.glmnet(X, y, alpha = 1, nfolds = 10)
    results[i, ] <- as.numeric(coef(fit, s = "lambda.min"))
  }
  data.frame(
    coefficient = c("intercept", paste0("beta_", seq_len(p))),
    true_value = c(0, beta_true),
    bias = colMeans(results) - c(0, beta_true),
    variance = apply(results, 2, var)
  )
}

settings <- list(
  baseline = list(beta = beta_base, noise_sd = 1),
  larger_noise = list(beta = beta_base, noise_sd = 3),
  smaller_coefficients = list(beta = c(1, 0.5, 0, 0, 0.5, rep(0, 5)), noise_sd = 1),
  larger_coefficients = list(beta = c(5, 3, 0, 0, 4, rep(0, 5)), noise_sd = 1)
)
for (name in names(settings)) {
  cfg <- settings[[name]]
  cat("\n===", name, "===\n")
  print(simulate_lasso(cfg$beta, cfg$noise_sd, n_sim, n, p), row.names = FALSE)
}
