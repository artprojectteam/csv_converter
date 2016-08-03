export default function(size){
  const $kb = 1024,
    $mb = Math.pow($kb, 2),
    $gb = Math.pow($kb, 3),
    $tb = Math.pow($kb, 4);
  
  let target = 0,
    unit = 'byte',
    new_size = size,
    isCalc = true;
  
  switch(true){
    case size >= $tb:
      target = $tb;
      unit = 'TB';
      break;
    case size >= $gb:
      target = $gb;
      unit = 'GB';
      break;
    case size >= $mb:
      target = $mb;
      unit = 'MB';
      break;
    case size >= $kb:
      target = $kb;
      unit = 'KB';
      break;
    default:
      isCalc = false;
      break;
  }
  
  if(!!isCalc) new_size = Math.floor((size / target) * Math.pow(10,2)) / Math.pow(10,2);
  
  return new_size + unit;
}