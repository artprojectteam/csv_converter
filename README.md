# CSV Converter

CSVファイルをJSON,シリアライズ化してダウンロードすることが出来ます。<br>
http://tools.artprojectteam.jp/csv/

## 特徴

サーバにファイルを保管せずにファイルをダウンロードするため、サーバにはデータが残らない。<br>
任意の改行コードを指定できる。

## 仕組み

1. CSVファイルをドロップ
1. ドロップされたCSVファイルのデータを読み取る
1. **ダウンロード**をクリックするとAjaxを利用し、PHPでコンバートタイプに合わせた結果を返却する
1. 返却されたデータをHTML5のBlobを利用してダウンロードする




## 対応ブラウザ

- Google Chrome
- Mozilla Firefox
- Safari

※IE,スマートフォンには対応していません

