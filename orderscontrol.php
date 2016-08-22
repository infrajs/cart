<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
infra_require('*cart/cart.inc.php');
$ans=array();
$place=$_REQUEST['place'];
if(!infra_session_get('safe.manager'))return infra_err($ans,'У вас нет доступа к этому разделу. Вы не являетесь Менеджером.');
if(isset($_REQUEST['id'])){
	$id=$_REQUEST['id'];
	$ans['id']=$id;
	$order=cart_getGoodOrder($id);
	if(!$order)return infra_err($ans,'Заявка {id} не найдена');
	$order['place']=$place;	
	$ans['order']=$order;
	return infra_ret($ans);
}else{
	$orders=array();
	$conf=infra_config();
	$src=$conf['cart']['ordersdir'];
	$src=infra_theme($src);
	$file_list=glob(ROOT.$src."*");
	foreach($file_list as $file){
		$f=infra_srcinfo($file);
		if($f['ext']!=='json')continue;
		$id=$f['name'];
		$order=cart_getGoodOrder($id);
		$order['place']=$place;
		//if($order['status']=='active')continue;
		$orders[]=$order;
	}
	usort($orders,function($o1,$o2){
		/*if($o2['status']!=$o1['status']){
			if($o2['status']=='check')return 1;//check выше всего
			if($o1['status']=='check')return -1;//check выше всего

			if($o1['status']=='active')return 1;//Всё выше чем active
			if($o2['status']=='active')return -1;//Всё выше чем active

			if($o1['status']=='saved')return 1;//выше чем active
			if($o2['status']=='saved')return -1;//выше чем active
		}*/
		if($o2['time']>$o1['time'])return 1;

	});
	
	return infra_echo(array("products"=>$orders), '', 1);
}

?>