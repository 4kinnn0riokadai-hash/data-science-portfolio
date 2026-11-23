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

## データの取得方法

Kaggleのコンペデータは利用規約への同意が必要です。再配布の許可を確認できないため、**`train.csv`・`test.csv` 本体はこの公開リポジトリに含めていません**。データは各自のKaggleアカウントで公式サイトから取得してください。

- [Kaggleの公式データページ](https://www.kaggle.com/competitions/house-prices-advanced-regression-techniques/data)
- [Kaggle公式API・認証の案内](https://www.kaggle.com/docs/api)

### 方法1：ブラウザから入手

1. Kaggleにログインし、コンペの参加規約に同意する。
2. 公式データページから `train.csv` と `test.csv` をダウンロードする。
3. 2ファイルを、このREADMEと同じ `projects/house-price-prediction/` フォルダに置く。

### 方法2：Kaggle CLIで入手

Kaggle公式CLIをインストールし、Kaggle側で認証・参加規約への同意を済ませてから、このディレクトリで実行する。

```powershell
python -m pip install kaggle
python download_data.py
```

このリポジトリの [`download_data.py`](download_data.py) はKaggle公式CLIから配布ZIPをダウンロードし、`train.csv` と `test.csv` をNotebookと同じディレクトリに取り出すための補助スクリプトです。認証情報やCSV本体をGitHubにアップロードする必要はありません。

## Notebookの実行と注意

`train.csv` と `test.csv` をNotebookと同じ作業ディレクトリに配置し、必要なPythonライブラリをインストールして実行する想定です。

- 公式データは利用者自身がKaggleから入手する必要があります。
- 整理版Notebookの再実行確認、交差検証・ホールドアウト評価は**未実施**。Kaggleスコア・順位は主張しません。
- 当時の演習コードを残しており、欠損値補完やカテゴリ変数処理などには改善の余地があります。
- 補助ダウンロードスクリプトも、Kaggle認証済みの環境での実動作確認はまだ行っていません。
