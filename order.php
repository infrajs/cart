<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
//sleep(1);
infra_require('*cart/cart.inc.php');

$id=$_REQUEST['id'];
$ans=array('id'=>$id);
$place=$_REQUEST['place'];
$safe=infra_session_get('safe');
if(!Cart::loadOrder($id))return infra_err($ans,'Заявка не найдена!');
if(!infra_session_get('safe.manager')&&!cart_isMy($id))return infra_err($ans,'Заявки нет в списке ваших заявок!');
if(!infra_session_get('safe.manager')&&$place=='admin')return infra_err($ans,'У вас нет доступа к этому разделу!');
if(!cart_canI($id))return infra_err($ans,'Действие не разрешено!');

//Заява либо моя либо это менеджер
if(isset($_GET['easy'])){
	$order=Cart::loadOrder($id);
}else{
	$order=Cart::getGoodOrder($id);
	$order['place']=$place;
	$order['user']=Load::loadJSON('*cart/user.php');
	//if($id&&$order['status']=='active'){
		$order['ismy']=cart_isMy($id);
		//return infra_err($order,'Активная заявка {id} редактируется пользователем {email}');
	//}
	//if($id&&$order['status']=='active'){
	//	$order=array(
	//		"id"=>$id,
	//		"email"=>$order["email"],
	//		"activebutton"=>cart_isMy($id)
	//	);
	//	return infra_err($order,'Активная заявка {id} редактируется пользователем {email}');
	//}
}
return infra_ret($order,'Ваша заявка');
?>