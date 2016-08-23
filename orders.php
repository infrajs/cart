<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
infra_require('*cart/cart.inc.php');
$ans=array('result'=>1);
//$ans['email']=infra_session_getEmail();
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
		if(!infra_session_get('safe.manager')&&!Cart::isMy($id))return infra_err($ans,'Заявки нет в списке ваших заявок!');
		return infra_ret($order);
	}
}else{
	$ans = array();	
	$ans['order']=Cart::getGoodOrder();
	$ans['list']=cart_getMyOrders();
	
	return infra_ret($ans);
}
?>