"""Kaggle公式CLIから住宅価格予測コンペのCSVを個人用に取得する。

利用前にKaggleにログインし、コンペの参加規約へ同意してください。
取得したデータは公開GitHubに再配布しないでください。
"""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile

COMPETITION = "house-prices-advanced-regression-techniques"
FILES = ("train.csv", "test.csv")


def main() -> int:
    destination = Path(__file__).resolve().parent
    if all((destination / filename).is_file() for filename in FILES):
        print("train.csv と test.csv は既に存在します。")
        return 0

    if shutil.which("kaggle") is None:
        print(
            "Kaggle CLI がありません。'python -m pip install kaggle' を実行してください。",
            file=sys.stderr,
        )
        return 1

    with tempfile.TemporaryDirectory(prefix="kaggle-house-prices-") as temporary:
        download_dir = Path(temporary)
        command = [
            "kaggle", "competitions", "download",
            "-c", COMPETITION, "-p", str(download_dir),
        ]
        print("Kaggle公式CLIからデータを取得します（事前に規約への同意と認証が必要）。")
        try:
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError:
            print(
                "ダウンロード失敗。Kaggleにログインし、コンペの規約に同意したか確認してください。",
                file=sys.stderr,
            )
            return 1

        archives = list(download_dir.glob("*.zip"))
        if archives:
            archive = archives[0]
            with zipfile.ZipFile(archive) as zf:
                for filename in FILES:
                    candidates = [
                        member for member in zf.namelist()
                        if Path(member).name == filename
                    ]
                    if len(candidates) != 1:
                        raise RuntimeError(f"{filename} がZIP内に見つかりません")
                    with zf.open(candidates[0]) as source:
                        with (destination / filename).open("wb") as target:
                            shutil.copyfileobj(source, target)
        else:
            for filename in FILES:
                source = download_dir / filename
                if not source.is_file():
                    raise RuntimeError(f"{filename} がダウンロード先に見つかりません")
                shutil.copy2(source, destination / filename)

    for filename in FILES:
        path = destination / filename
        print(f"取得完了: {path.name} ({path.stat().st_size:,} bytes)")
    print("データは .gitignore によりGitへ追加されません。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
