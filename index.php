<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\user\User;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\access\Access;
use infrajs\session\Session;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}

Nostore::on();

$type = Ans::GET('type', 'string', false);
if (!$type) return Ans::err($ans, 'Требуется параметр type');

if ($type = 'user') {
	$ans = User::get();
	$ans['manager'] = Session::get('safe.manager');
	return Ans::ret($ans);
} 

if ($type == 'office') {
	if ($_REQUEST['submit']) {
		$ans = array('msg'=>'','result'=>0);
		
		if (Access::admin() && Session::getEmail()) {
			if($_REQUEST['IAmManager'])
				Session::set('safe.manager',true);
			else
				Session::set('safe.manager',false);
			return Ans::ret($ans);
		}else{
			return Ans::err($ans,'У вас недостаточно прав!');
		}
	}



	$orders = Cart::getMyOrders();
	$order = Cart::getGoodOrder();

	$ans['order']=$order;


	$list=array();
	Each::forr($orders,function($order) use(&$list){
		$status=$order['status'];
		if(!$list[$status])$list[$status]=array();
		$list[$status][]=array(
			'id'=>$order['id'],
			'time'=>$order['time']
		);
	});
	$ans['rules']=Load::loadJSON('*cart/rules.json');
	$ans['list']=$list;
	$ans['admin']=Access::admin();
	$ans['email']=Session::getEmail();
	$ans['manager']=Session::get('safe.manager');

	return Ans::ret($ans);
}

return Ans::err($ans,'Передан незарегистрированный type');