import {BRZ} from 'browzection.es6';
require('angular');
require('angular-animate');

// モジュール
require('./_assets/apps/fileDrop');


angular
  .module('csvApp', [
    'csvApp.fileDrop'
  ])
  .controller('CsvController', ['$scope', function($scope){
    $scope.isNotSupport = false;
    let isFileAPI = window.File && window.FileReader && window.FileList && window.Blob;
  
    if(!isFileAPI || !!BRZ.ie.flg){
      $scope.isNotSupport = true;
    }
  }])
  .directive('noSupport', [function(){
    return {
      restrict: 'E',
      templateUrl: 'angular/no_support.html',
      scope: {
        value: "="
      },
      replace: true
    }
  }]);


