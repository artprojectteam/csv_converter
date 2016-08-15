<?php
setlocale(LC_ALL, 'ja_JP.UTF-8');

/**
 * CSVファイルのコンバート
 */
if($_SERVER['REQUEST_METHOD'] !== 'POST' || (!isset($_POST['option']) && !isset($_POST['d']))){
  die;
}

$option   = $_POST['option'];
$encode_data = $_POST['d'];

// 改行コードの設定
$br_code = $option['line'] === '\r\n' ? array("\r\n", "\r", "\n") : $option['line'];


// データのみ抽出
$mime = 'data:'.htmlentities('text/csv', ENT_QUOTES, 'UTF-8').';base64,';
$data = base64_decode(str_replace($mime, '', $encode_data));
$data = mb_convert_encoding($data, 'UTF-8', 'UTF-8, sjis-win, SJIS, eucjp-win');    // 文字コードをUTF-8に変換

// データを配列に変換
$_substitution = '[csv_convert/vv]';
$csv_arr = str_replace($br_code, $_substitution, $data);
$csv_arr = explode($_substitution, $csv_arr);


// 配列内のCSVデータをパース
$csv_temp = array();
foreach($csv_arr as $c){
  $csv_temp[] = str_getcsv($c);
}

// 配列の数を確認
$total = count($csv_temp);


// 成形用の初期化
$csv_data_temp = array();
$csv_data = array();

// タイトル行をキー名にするかどうか
switch($option['title']){
  case 'true':
    for($i = 1; $i < $total; $i++){
      $temp = $csv_temp[$i];
      $_t = array();
      $_n = 0;
      if($temp[0] === null) continue;   // 子配列の最初がnullの場合は無視
      
      foreach($temp as $k=>$v){
        $key = $csv_temp[0][$_n];
        $_c = trim($v, " \t\n\r\0\x0B");
        $_c = str_replace(array("\r\n", "\r", "\n"), '<br>', $_c);
        $str = htmlspecialchars($_c, ENT_QUOTES, 'UTF-8');
        
        if($key === '' && $str === '') continue;
        
        $_t[][$key] = $str;
        $_n++;
      }
      $csv_data[] = $_t;
    }
    break;
  default:
    for($i = 0; $i < $total; $i++){
      $temp = $csv_temp[$i];
      $_t = array();
      if($temp[0] === null) continue;   // 子配列の最初がnullの場合は無視
      
      foreach($temp as $k=>$v){
        $str = htmlspecialchars($v, ENT_QUOTES, 'UTF-8');
        $_t[] = $str;
      }
      
      $csv_data[] = $_t;
    }
    break;
}


switch($option['type']){
  case 'json':
    $res = json_encode($csv_data, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
    $header_content = 'application/json';
    break;
  case 'serialize':
    $res = serialize($csv_data);
    $header_content = 'text/plain';
    break;
//  case 'php':
//    $res = $csv_data;
//    break;
  default:
    $res = null;
    $header_content = 'text/plain';
    break;
}

header('Content-type: '.$header_content);
echo $res;