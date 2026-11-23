# Kaggle住宅価格予測（Python）

**区分**：大学の講義・個人演習  
**題材**：[Kaggle House Prices - Advanced Regression Techniques](https://www.kaggle.com/competitions/house-prices-advanced-regression-techniques)

## 目的と担当範囲

住宅の面積・設備などの情報から販売価格 `SalePrice` を予測する演習。学習データ約1,460件に対し、Pythonで次の処理を行った。

1. pandasでデータを読み込み、欠損状況を確認。
2. 数値列の一部を中央値で補完し、カテゴリ値をエンコーディング。
3. 面積を合算した特徴量 `TotalSF` を追加。
4. Lasso・LightGBM・XGBoostの3モデルを学習し、予測結果を平均。
5. Kaggleの提出形式の `submission.csv` を生成するコードを記述。

**使用技術**：Python、pandas、NumPy、scikit-learn、LightGBM、XGBoost

**[公開用Notebook（個人情報・実行結果を除去）](house_price_models.ipynb)**

## 再現方法と注意

Kaggleから配布される `train.csv`、`test.csv` をNotebookと同じ作業ディレクトリに配置し、必要なPythonライブラリをインストールして実行する想定。

- データファイルは再配布していない。
- この整理版の実行確認、交差検証・ホールドアウト評価は**未実施**。Kaggleスコア・順位は主張しない。
- 当時の演習コードを残しており、欠損値補完やカテゴリ変数処理などには改善の余地がある。
