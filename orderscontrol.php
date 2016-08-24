<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\access\Access;
use infrajs\ans\Ans;
use infrajs\session\Session;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}


$ans=array();
$place=$_REQUEST['place'];
if(!Session::get('safe.manager'))return infra_err($ans,'У вас нет доступа к этому разделу. Вы не являетесь Менеджером.');
if(isset($_REQUEST['id'])){
	$id=$_REQUEST['id'];
	$ans['id']=$id;
	$order=Cart::getGoodOrder($id);
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
		$order=Cart::getGoodOrder($id);
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