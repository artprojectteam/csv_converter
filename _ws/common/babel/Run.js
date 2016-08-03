require('angular');
require('angular-animate');

// モジュール
require('./_assets/apps/fileDrop');

angular
  .module('csvApp', [
    'csvApp.fileDrop'
  ])
  .controller('CsvController', [function(){
    let isFileAPI = window.File && window.FileReader && window.FileList && window.Blob;
    
    if(!isFileAPI){
      // todo:対応していない場合
    }
  }]);


