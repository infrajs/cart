<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
infra_require('*cart/cart.inc.php');
$id=(int)$_REQUEST['id'];
$action=$_REQUEST['action'];
$ans=array('id'=>$id,'action'=>$action);
$place=$_REQUEST['place'];
//sleep(5);
if($action=='wholesaleDelete'){	
	if(!infra_session_get('safe.manager'))return infra_err($ans, 'У вас нет доступа!');
	$email=$_REQUEST['id'];
	$data=Load::loadJSON('*merchants.json');
	unset($data['merchants'][$email]);
	file_put_contents(ROOT.'infra/data/merchants.json', infra_json_encode($data));
	return infra_ret($ans);
}

$order = Cart::loadOrder($id);
if(infra_session_get('safe.manager')||$order['rule']['edit']['orders']){ //Place - orders admin wholesale
	cart_mergeOrder($order,$place);
}
//Заявка принадлежит тому человеку, который первым изменил её статус с активного на какой-то
//Передать заявку может и можно, но сумма по заявке будет всегда принадлежать первому человеку

if(!Cart::canI($id,$action))return infra_err($ans,'У вас нет доступа к заявке {id}<br>на совершение действия {action}!');

if(!$order)return infra_err($ans,'Заявка {id} не найдена');
$status=$order['status'];

//На проверку может отправить и менеджер и пользователь, менедежр не может активную отправить на проверку
//Если в текущем статусе были разрешены изменения, значит нужно проверить введёные данные
//Если изменения не разрешены, значит нужно чтобы они не применялись из сессии
//Изменения могут быть порциональными, тут можно тут нельзя, ???
//Изменять статус можно и без строкой проверки данных, сохранить можно любые данные? Это касается только saved


if(!in_array($action,array('realdel','clear'))){
	$msg=cart_checkReg($order['email']);
	if(is_string($msg))return infra_err($ans,$msg);
}

$ogood=Cart::getGoodOrder($id);
if(!in_array($action,array('realdel','active','clear','saved','dismiss'))&&$ogood['rule']['edit'][$place]){
	if(!$order['basket'])return infra_err($ans,'Заявк пустая! Добавьте товар!');
	$page='';
	if(!cart_checkData($order['phone'],'value'))return infra_err($ans,'Укажите корректный телефон'.$page);
	if(!cart_checkData($order['name'],'value'))return infra_err($ans,'Укажите корректное имя контактного лица'.$page);
	if(!cart_checkData($order['entity'],'radio'))return infra_err($ans,'Укажите кто будет оплачивать'.$page);
	if(!cart_checkData($order['paymenttype'],'radio'))return infra_err($ans,'Укажите способ оплаты'.$page);
	if(!cart_checkData($order['delivery'],'radio'))return infra_err($ans,'Укажите способ доставки'.$page);
	

	if($order['entity']=='legal'){
		if(!cart_checkData($order['details'],'radio'))return infra_err($ans,'Необходимо заполнить реквизиты'.$page);
		if($order['details']=='allentity'){
			if(!cart_checkData($order['allentity'],'value'))return infra_err($ans,'Необходимо указать реквизиты'.$page);
		}else{
			if(!cart_checkData($order['company'],'value'))return infra_err($ans,'Укажите название юр.лица'.$page);
			if(!cart_checkData($order['inn'],'value'))return infra_err($ans,'Укажите ИНН'.$page);
			if(!cart_checkData($order['addreslegal'],'value'))return infra_err($ans,'Укажите адрес юр.лица'.$page);
			if(!cart_checkData($order['addrespochta'],'value'))return infra_err($ans,'Укажите почтовый адрес юр.лица'.$page);
		}
	}

	if($order['delivery']=='delivery'){
		if(!cart_checkData($order['addresdelivery'],'value'))return infra_err($ans,'Укажите адрес доставки'.$page);
	}
}


if($action=='saved'){

	if(!$order['basket'])return infra_err($ans,'Заявк пустая! Добавьте товар!');
	$msg=cart_checkReg($order['email']);
	if(is_string($msg))return infra_err($ans,$msg);
	$order['status']='saved';
	cart_saveOrder($order,$place);
	if($status=='active'){
		infra_session_set('user.basket');//Очистили Текущую активную заявку
		infra_session_set('user.id');
		infra_session_set('user.fixid');
		infra_session_set('user.copyid');
		infra_session_set('user.time');
		infra_session_set('user.manage');
	}
}elseif($action=='removechanges'){
	if($order['status']=='active')return infra_err($ans,'У активной заявки нельзя отменить изменения');
	//Если я user нужно удалить user{id} сессию иначе надо удалить manager{id} сессию 
	//Нужно знать с какого места осуществлён вызов чтобы определит что делать
	if($place=='admin'&&!infra_session_get('safe.manager'))return infra_err($ans, 'У вас нет доступа!');
	infra_session_set($place.$id);
}elseif($action=='refresh'){//Обновить данные из каталога
	Each::foro($order['basket'],function(&$pos){
		unset($pos['article']);//Если нет артикула данные при сохранении обновятся
	});
	cart_saveOrder($order,$place);
}elseif($action=='setPaid'){//Обновить данные из каталога

	if($order['manage']['paid'])return infra_err($ans,'По заявке {id} уже есть отметка об оплате {paid}');
	$order['manage']['paid']=$ogood['alltotal'];
	$order['manage']['paidtime']=time();
	$order['manage']['paidtype']='manager';
	cart_saveOrder($order,$place);
}elseif($action=='savechanges'){
	cart_saveOrder($order,$place);//К order применились изменения и после сохранения эти изменения будут доступны другим
}elseif($action=='check'){
	$order['status']='check';
	cart_saveOrder($order,$place);
	if($status=='active'){
		infra_session_set('user.basket');//Очистили заявку
		infra_session_set('user.id');
		infra_session_set('user.fixid');
		infra_session_set('user.copyid');
		infra_session_set('user.time');
		infra_session_set('user.manage');
	}
}elseif($action=='active'){
	
	$noworder = Cart::loadOrder();
	if($noworder['basket']){
		return infra_err($ans,
			'У вас уже есть <a onclick="cart.goTop(); popup.close()" href="?office/orders/my">активная непустая заявка</a>.<br>
			Чтобы сделать заявку активной нужно<br>
			очистить или сохранить текущую активную заявку!');
	}
	$order['status']='active';
	cart_saveOrder($order,$place);
}elseif($action=='copy'){

	$noworder = Cart::loadOrder();
	if($noworder['basket']){
		return infra_err($ans,
			'У вас уже есть <a onclick="cart.goTop(); popup.close()" href="?office/orders/my">активная непустая заявка</a>.<br>
			Чтобы сделать копию заявки нужно<br>
			очистить или сохранить текущую активную заявку!');
	}

	$order['copyid']=$order['id'];
	unset($order['fixid']);
	unset($order['id']);
	unset($order['manage']);

	$order['status']='active';
	cart_saveOrder($order,$place);

}elseif($action=='realdel'){
	
	$myorders=infra_session_get('safe.orders',array());
	infra_forr($myorders,function($id) use($order){
		if($order['id']==$id)return new infra_Fix('del',true);
	});
	$path=Cart::getPath($id);
	$src=infra_theme($path);
	if($src)unlink(ROOT.$src);

}elseif($action=='clear'){
	if(!$order['basket'])return infra_err($ans,'Корзина уже пустая');
	unset($order['basket']);
	if($order['status']=='active'){
		infra_session_set('user.basket');
	}else{
		cart_saveOrder($order,$place);
	} 


}elseif($action=='refuseable'){
	$order['status']='refunds';
	cart_saveOrder($order,$place);
}elseif($action=='ready'){
	$order['status']='ready';
	cart_saveOrder($order,$place);
}elseif($action=='execution'){
	$order['status']='execution';
	cart_saveOrder($order,$place);
}elseif($action=='dismiss'){
	$order['status']='dismiss';
	cart_saveOrder($order,$place);
}elseif($action=='picked'){
	$order['status']='picked';
	cart_saveOrder($order,$place);
}elseif($action=='delivery'){
	$order['status']='delivery';
	cart_saveOrder($order,$place);
}elseif($action=='complete'){
	$order['status']='complete';
	cart_saveOrder($order,$place);
}elseif($action=='editcart'){
	
	if(!$id)return infra_err($ans,'Нельзя активную заявку сделать активной');
	$ans=Load::loadJSON('*cart/orderActions.php?place='.$place.'&id='.$id.'&action=active');
	if(!$ans['result'])return infra_ans($ans);
	$order=Cart::loadOrder();//Активную заявку сделать активной нельзя... был id а тут его нет

}else{
	return infra_err($ans,'Действие {action} не найдено!');
}

return cart_ret($order,$action);
?>