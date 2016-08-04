require('Zepto');
require('angular');
require('angular-animate');

import CalcFileSize from '../util/calcFileSize';

module.exports = angular
  .module('csvApp.fileDrop', [
    'ngAnimate'
  ])
  .constant('FILES', {
    ERROR: {
      MULTIPLE: 'コンバートできるファイルは1枚のみです',
      FILE_TYPE: 'コンパートできるファイルタイプはtext/csvのみです',
      READ: 'ファイルを読み取れませんでした'
    },
    TYPE: {
      JSON: {id: 'json', name: 'JSON'},
      SERIALIZE: {id: 'serialize', name: 'Serialize'}
      // PHP: {id: 'php', name: 'PHP'}
    },
    LINE_CODE: '\\r\\n',
    TITLE_LINE: true
  })
  .run(function($rootScope, FILES){
    $rootScope.FILES = FILES;
  })
  .controller('DropController', ['$rootScope', '$scope', '$http', '$httpParamSerializerJQLike', function($rootScope, $scope, $http, $httpParamSerializerJQLike){
    $scope.isResult = false;
    $scope.isDropError = false;
    $scope.progress = 0;
    $scope.result = {
      hidden: true
    };
    
    $scope.dropErrorMsg = '';
    
    $scope.selected = $rootScope.FILES.TYPE;
    $scope.lineCode = $rootScope.FILES.LINE_CODE;
    $scope.titleLine = $rootScope.FILES.TITLE_LINE;
    
    $scope.titleLine_default = $rootScope.FILES.TITLE_LINE;
    $scope.file = {};
    
    $scope.convert = {
      name: '',
      type: $rootScope.FILES.TYPE.JSON.id,
      line: $scope.lineCode,
      title: $scope.titleLine
    };
    
    $scope.download_name = '';
    
    /**
     * ファイルドロップ後
     * @param $event
     */
    $scope.drop = ($event)=>{
      $event.stopPropagation();
      $event.preventDefault();
      
      $('#fileDrop').removeClass('dropping');
      
      let files = $event.dataTransfer.files;
      
      if(files.length > 1){
        // ファイルが複数の場合はエラー
        $scope.isDropError = true;
        $scope.isResult = false;
        $scope.dropErrorMsg = $rootScope.FILES.ERROR.MULTIPLE;
        $('#progress').attr('aria-hidden', 'true');
        return false;
      }
      
      let file = files[0];
      
      if(file.type !== 'text/csv'){
        // CSV以外はエラー
        $scope.isDropError = true;
        $scope.isResult = false;
        $scope.dropErrorMsg = $rootScope.FILES.ERROR.FILE_TYPE;
        $('#progress').attr('aria-hidden', 'true');
        return false;
      }
      
      let reader = new FileReader();
      
      
      reader.onload = (evt)=>{
        /* memo:読み込み完了 */
        $scope.$apply(()=>{
          $scope.result = {
            hidden: false,
            file: file.name,
            size: CalcFileSize(file.size)
          };
          
          $scope.convert.name = file.name;
        });
      };
      
      reader.onloadstart = (evt)=>{
        /* memo:処理開始 */
        $scope.$apply(()=>{
          $scope.progress = 0;
        });
        $('#progress').attr('aria-hidden', 'false');
      };
      
      reader.onloadend = (evt)=>{
        /* memo:処理完了後 */
        $scope.$apply(()=>{
          $scope.isResult = true;
          $scope.isDropError = false;
        });
        
        $scope.file = evt.target.result;
        
        setTimeout(()=>{
          $('#fileDrop').addClass('res');
          $('#progress').attr('aria-hidden', 'true');
        }, 200);
      };
      
      reader.onprogress = (evt)=>{
        /* memo:処理中 */
        $scope.$apply(()=>{
          $scope.progress = Math.round((evt.loaded / evt.total) * 100);
        });
      };
      
      reader.onerror = (stuff)=>{
        /* memo:エラー */
        $scope.isDropError = true;
        $scope.isResult = false;
        $scope.dropErrorMsg = $rootScope.FILES.ERROR.READ;
      };
      
      reader.readAsDataURL(file);   // ファイル読み込み
    };
    
    /**
     * ファイルドロップ中
     * @param $event
     */
    $scope.dragOver = ($event)=>{
      $event.stopPropagation();
      $event.preventDefault();
      
      $event.dataTransfer.dropEffect = 'copy';
      $('#fileDrop').addClass('dropping');
    };
    
    /**
     * 改行コードリセット
     */
    $scope.onLineReset = ()=>{
      $scope.convert.line = $rootScope.FILES.LINE_CODE;
    };
    
    
    /**
     * コンバート実行
     */
    $scope.doConvert = ()=>{
      $scope.progress = 50;
      $('#progress').attr('aria-hidden', 'false');
      let ops = {
        type: $scope.convert.type,
        line: $scope.convert.line,
        title: $scope.convert.title
      };
      
      
      $http({
        method: 'POST',
        url: 'application/convert.php',
        transformRequest: $httpParamSerializerJQLike,
        headers: {
          'Content-Type' : 'application/x-www-form-urlencoded;charset=utf-8'
        },
        data: {
          option: ops,
          d: $scope.file
        }
      })
        .success((data, status, headers, config)=>{
          let content_type = '',
            file_name = $scope.convert.name.replace(/\.csv/, ''),
            res;
          
          switch(ops.type){
            case $rootScope.FILES.TYPE.JSON.id:
              content_type = 'application\/json';
              res = JSON.stringify(data);
              $scope.download_name = `${file_name}.json`;
              break;
            case $rootScope.FILES.TYPE.SERIALIZE.id:
              content_type = 'plain\/text';
              res = data;
              $scope.download_name = `${file_name}.serialize`;
              break;
            default:
              break;
          }
          
          let blob = new Blob([res], {'type': content_type});
          
          // todo: ブラウザごとの挙動を追加
          window.URL = window.URL || window.webkitURL;
          $scope.progress = 100;
          
          setTimeout(()=>{
            $('#download')
              .attr('href', window.URL.createObjectURL(blob))
              .trigger('click');
            $('#progress').attr('aria-hidden', 'true');
          }, 100);
          
        })
        .error((data, status, headers, config)=>{
          console.log('失敗');
        });
    };
  }])
  .directive('ngDrop', function($parse){
    return {
      restrict: 'A',
      link: ($scope, element, attrs)=>{
        element.bind('drop', (ev)=>{
          let fn = $parse(attrs.ngDrop);
          $scope.$apply(()=>{
            fn($scope, {$event: ev});
          });
        });
      }
    }
  })
  .directive('ngDragover', function($parse){
    return {
      restrict: 'A',
      link: ($scope, element, attrs)=>{
        element.bind('dragover', (ev)=>{
          let fn = $parse(attrs.ngDragover);
          $scope.$apply(()=>{
            fn($scope, {$event: ev});
          });
        });
      }
    }
  })
  .directive('progressbar', function(){
    return {
      restrict: 'E',
      templateUrl: 'angular/progressbar.html',
      scope: {
        value: '='
      },
      replace: true
    }
  })
  .directive('resultArea', [function(){
    return {
      restrict: 'AE',
      transclude: true,
      templateUrl: 'angular/result.html',
      scope: {
        value: '='
      },
      replace: true,
      link: (scope, elem, attrs)=>{
      }
    }
  }])
  .directive('dropErrorArea', [function(){
    return {
      restrict: 'AE',
      transclude: true,
      templateUrl: 'angular/dropError.html',
      scope: {
        value: '='
      },
      replace: true,
      link: (scope, elem, attrs)=>{
      }
    }
  }]);