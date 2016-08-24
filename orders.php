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

$ans = array('result'=>1);
//$ans['email']=Session::getEmail();
$id=$_REQUEST['id'];
$ans['id']=$id;
//if(!Cart::canI($id))return infra_err($ans,'У вас недостаточно прав, для просмотра этой страницы');
if($id){
	if(!$id){
		// работаем с активной заявкой
		$order=Cart::getGoodOrder();
		$ans['order']=$order;
		return infra_ret($ans);
	}else{
		// работаем с сохранённой заявкой
		$order=Cart::getGoodOrder($id);
		if(!$order)return infra_err($ans,'Заявка не найдена!');
		if(!Session::get('safe.manager')&&!Cart::isMy($id))return infra_err($ans,'Заявки нет в списке ваших заявок!');
		return infra_ret($order);
	}
}else{
	$ans = array();	
	$ans['order']=Cart::getGoodOrder();
	$ans['list']=cart_getMyOrders();
	
	return infra_ret($ans);
}
?>