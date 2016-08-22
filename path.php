<?php
	@define('ROOT','../../../');
	require_once(ROOT.'infra/plugins/infra/infra.php');
	infra_require('*cart/cart.inc.php');

	
	

	$val=$_GET['val'];
	$art=$_GET['art'];
	$ans=infra_admin_cache('path_php',function($val, $art){

		$type='hz';

		if(preg_match("/^p\d+$/",$art)){
			$type='nopos';
		}

		
		$search=infra_loadJSON('*cart/search.php?val='.$val);

		if($art!=""){
			$type="pos";
		}else if($search["is"]){
			$type=$search["is"];
		}
		if(preg_match("/^p\d+$/",$art)){
			$type='nopos';
		}

		$list=array();
		$list[]=array('name'=>'Каталог','href'=>'?Каталог/Каталог');
		if($type=='producer'){
			$list[]=array('name'=>'Производители','href'=>'?Каталог/Производители');
			$list[]=array('name'=>$search["list"][0]["Производитель"],'href'=>'?Каталог/'.$search["list"][0]["Производитель"]);
		}else if($type=='group'||$type=="nopos"){
			if($val!=="Каталог"){
				if($search["list"][0]){
					$path = $search["list"][0]["path"];
					for($i=0; $i<sizeof($path); $i++){
						if($path[$i]==$val){
							break;
						}
					}
					$realPath = array_slice($path, 0, $i+1);
					for($i=0; $i < sizeof($realPath); $i++){
						$list[]=array('name'=>$realPath[$i], 'href'=>'?Каталог/'.$realPath[$i]);
					}
				}
			}
		}else if($type=="pos"){
						//echo "<pre>";
						//print($art);
						//print_r($search['list']);
						//exit;
			//$list[]=array('name'=>'Производители','href'=>'?Каталог/Производители');
			for($i=0; $i < sizeof($search["list"]); $i++){
				//echo $art."<br>";
				//echo $search["list"][$i]["article"]."<br>"; // нет таких позиций в выборке пример http://localhost/git/kvant63.ru/?%D0%9A%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3/%D0%90%D1%80%D1%82%D0%B8%D0%BA%D1%83%D0%BB/%D0%A8%D0%9F%D0%9A-310%20%D0%9D%D0%9E%D0%91
				$data = cat_init();
				$pos = xls_runPoss($data, function($p) use ($val, $art){
					if($p['Производитель'] == $val && $p['article'] == $art){
						return $p;
					}
				});
				if($pos){
					$path = $pos["path"];
					for($j=0; $j<sizeof($path); $j++){
						$list[]=array('name'=>$path[$j], 'href'=>'?Каталог/'.$path[$j]);
					}
					//$realPath = array_slice($path, 0, $i+1);
					//for($i=0; $i < sizeof($realPath); $i++){
					//	echo "1";
					//	$list[]=array('name'=>$realPath[$i], 'href'=>'?Каталог/'.$realPath[$i]);
					//}

					$list[] = array("name" => $pos["Производитель"], "href" => "?Каталог/".$pos["Производитель"]);
					$list[] = array("name" => $pos["article"], "href" => "?Каталог/".$pos["article"]);
					break;
				}
			}
		}else{
			$list[]=array('name'=>$val,'href'=>"?Каталог/".$val);
		}


		$ans=array();
		$ans['val']=$val;
		$ans['art']=$art;
		$ans['type']=$type;
		$ans['list']=$list;
		return $ans;
	}, array($val, $art), isset($GET["re"]));

	return infra_echo($ans);
?>