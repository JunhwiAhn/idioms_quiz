# Play Console 提出用アセット

## 既に用意されているもの

| ファイル | 用途 | サイズ |
|---|---|---|
| `icon_512.png` | 高解像度アイコン (Play Console「高解像度アイコン」欄) | 512 × 512 |
| `feature_graphic.png` | フィーチャーグラフィック | 1024 × 500 |
| `screenshots/00_splash.png` | スクリーンショット #1 — スプラッシュ | 1080 × 2400 |
| `screenshots/01_home.png` | スクリーンショット #2 — ホーム画面 | 1080 × 2400 |
| `screenshots/02_quiz.png` | スクリーンショット #3 — クイズ画面 (正解/不正解ハイライト) | 1080 × 2400 |

Play Console のスクリーンショット要件は **最低 2 枚**、上限 8 枚。3 枚揃っていれば提出可能です。

## 追加で撮るとより訴求力が上がるもの

エミュレータ (emulator-5554) 起動中に、以下をターミナルで実行すると追加スクリーンショットが撮れます:

```bash
ADB=~/Library/Android/sdk/platform-tools/adb
DIR=/Users/anjunhwi/Documents/GitHub/idioms_quiz/docs/play_assets/screenshots

# 図鑑 (右上 📚 アイコンをタップしてから実行)
$ADB exec-out screencap -p > $DIR/03_collection.png

# ステージ選択 (ステージタイルをタップしてから実行)
$ADB exec-out screencap -p > $DIR/04_stage.png

# クロスワード (クロスワードタイルをタップしてから実行)
$ADB exec-out screencap -p > $DIR/05_crossword.png

# リザルト画面 (1 クイズ完走してから実行)
$ADB exec-out screencap -p > $DIR/06_result.png
```

## プライバシーポリシー公開手順 (GitHub Pages)

1. GitHub リポジトリの **Settings → Pages**
2. **Build and deployment → Source**: `Deploy from a branch`
3. **Branch**: `main` / **folder**: `/docs`
4. **Save** → 数分後に `https://junhwiahn.github.io/idioms_quiz/` で公開
5. そのまま Play Console の「プライバシーポリシー URL」欄に貼り付け

GitHub Pages が有効になると `docs/index.html` がトップページとして表示されます。

## 使い方まとめ

1. Play Console の該当フォームに `docs/play_console_pack.md` の各セクションをコピー&ペースト
2. グラフィック類はこのフォルダから直接アップロード
3. AAB は `build/app/outputs/bundle/release/app-release.aab` をアップロード
4. 内部テスト → クローズドテスト → 製品版の順で昇格
