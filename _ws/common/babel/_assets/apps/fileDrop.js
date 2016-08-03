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
      FILE_TYPE: 'コンパートできるファイルタイプはtext/csvのみです'
    }
  })
  .run(function($rootScope, FILES){
    $rootScope.FILES = FILES;
  })
  .factory('DropError', function(){
    /* memo: Error処理 */
    return {
      message: (text)=>{
        console.log(text);
      }
    };
  })
  .controller('DropController', ['$rootScope', '$scope', '$http', 'DropError', function($rootScope, $scope, $http, DropError){
    $scope.isResult = false;
    $scope.progress = 0;
    $scope.result = {
      hidden: true
    };
    
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
        DropError.message($rootScope.FILES.ERROR.MULTIPLE);
        return false;
      }
      
      let file = files[0];
      
      if(file.type !== 'text/csv'){
        // CSV以外はエラー
        DropError.message($rootScope.FILES.ERROR.FILE_TYPE);
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
          }
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
        });
        
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
    
    $scope.doConvert = ($event, type)=>{
      // e.preventDefault();
      // console.log($(this).data('convert'));
      console.log($event, type);
    };
  }])
  .directive('ngDrop', function($parse){
    return {
      restrict: 'A',
      link: ($scope, element, attrs)=>{
        element.bind('drop', (ev)=>{
          let fn = $parse(attrs.ngDrop);
          $scope.$apply(()=>{
            fn($scope, {$event:ev});
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
            fn($scope, {$event:ev});
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
  .directive('resultArea', ['$compile', function($compile){
    return {
      restrict: 'AE',
      transclude: true,
      templateUrl: 'angular/result.html',
      scope: {
        value: '='
      },
      replace: true,
      link: (scope, elem, attrs)=>{}
    }
  }]);