<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\access\Access;
use infrajs\session\Session;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}

$id = $_REQUEST['id'];
$ans = array('id'=>$id);
$place = $_REQUEST['place'];
$safe = Session::get('safe');
if (!Cart::loadOrder($id)) return Ans::err($ans,'Заявка не найдена!');
if (!Session::get('safe.manager') && !Cart::isMy($id)) return Ans::err($ans,'Заявки нет в списке ваших заявок!');
if (!Session::get('safe.manager') && $place=='admin') return Ans::err($ans,'У вас нет доступа к этому разделу!');
if (!Cart::canI($id)) return Ans::err($ans,'Действие не разрешено!');

//Заява либо моя либо это менеджер
if (isset($_GET['easy'])){
	$order = Cart::loadOrder($id);
}else{
	$order = Cart::getGoodOrder($id);
	$order['place']=$place;
	$order['user']=Load::loadJSON('-cart/user.php');
	//if ($id&&$order['status']=='active'){
		$order['ismy'] = Cart::isMy($id);
		//return Ans::err($order,'Активная заявка {id} редактируется пользователем {email}');
	//}
	//if ($id&&$order['status']=='active'){
	//	$order = array(
	//		"id"=>$id,
	//		"email"=>$order["email"],
	//		"activebutton"=>Cart::isMy($id)
	//	);
	//	return Ans::err($order,'Активная заявка {id} редактируется пользователем {email}');
	//}
}
return Ans::ret($order,'Ваша заявка');