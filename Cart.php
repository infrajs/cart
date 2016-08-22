<?php

infra_require('-files/xls.php');
infra_require('-cart/catalog.inc.php');
infra_require('-session/session.php');


function cart_getPath($id=''){
	infra_once('cart_getPath',function(){
		@mkdir(infra_tofs('infra/data/.Заявки/'));
	});
	if(!$id)return '~.Заявки/';
	return '~.Заявки/'.$id.'.json';
}

function cart_getOrderById($id=''){
	return cart_loadOrder($id);
}
function cart_mergeOrder(&$order,$place){
	if(!$order['id'])return;
	$actualdata=infra_session_get($place.$order['id'], array());
	infra_foro($actualdata,function(&$val,$name){
		if(!is_string($val))return;
		$val=trim(strip_tags($val));
	});
	if(!infra_session_get('safe.manager')||$place!='admin'){
		unset($actualdata['manage']);//Только админ на странице admin может менять manage
	}
	if($actualdata['manage']&&$order['manage'])$actualdata['manage']=array_merge($order['manage'],$actualdata['manage']);
	$order = array_merge($order, $actualdata);
}

function cart_loadOrder($id=''){
	//Результат этой фукции можно сохранять в файл она не добавляет лишних данных, но оптимизирует имеющиеся
	return infra_once('cart_getOrderById',function($id){
		if($id){
			$order=infra_loadJSON(cart_getPath($id));
			if(!$order)return false;//Нет такой заявки с таким id
			//$email=infra_session_getEmail();
			

			//У хранящейся Активной заявки есть id, но если мы по id обращаемся значит не нужно применять ту что в сессии user
			//if($order['status']=='active'){
			//	if($order['email']==$email){
			//		return cart_loadOrder();
			//	}
			//}
			//Применили последний автоsave
			//С какого места вызывали и чью сессию применять
			
			//Права доступа тут не проверяются
			//Менеджер Отредактировал заявку в admin перешёл в orders увидел тоже самое

			//Если я менеджер сессия применяется всегда.
			//Если не менеджер то только если разрешено в месте orders  
			$order['id']=$id;
		}else{
			$order=infra_session_get('user', array());
			infra_foro($order,function(&$val,$name){
				if(is_string($val))$val=trim($val);
			});//По идеи в сессии хранится email и он уже там есть, как и любые другие поля.
			$email=infra_session_getEmail();//Это единственное место где в заявку добавляется email
			if($email)$order['email']=$email;//Когда нет регистрации email берём из формы autosave
			$order['status']='active';
		}
		if(!$order['manage'])$order['manage']=array();
		return $order;
	},array($id));
}

function cart_saveOrder(&$order,$place=false){
	$id=$order['id'];
	if(!$id){
		if($order['fixid']){
			$id=$order['fixid'];//Заявка уже есть в списке моих заявок
		}else{
			$id=time();
			$src=cart_getPath($id);
			while(infra_theme($src)){
				$id++;
				$src=cart_getPath($id);
			}
			$myorders=infra_session_get('safe.orders',array());
			$myorders[]=$id;
			$myorders=array_values($myorders);//depricated fix old errors in session
			infra_session_set('safe.orders',$myorders);
		}
	}else{
		if($place){
			$src=cart_getPath($id);
			infra_session_set($place.$id);
		}
	}
	$rules=$rules=infra_loadJSON('-cart/rules.json');
	if($rules['rules'][$order['status']]['freeze']){//Текущий статус должен замораживать позиции
		infra_foro($order['basket'],function(&$pos,$prodart){
			if($pos['article'])return;
			$p=cat_getByProdart($prodart);
			if($p){//Товар найден в каталоге
				$pos=array_merge($p,array('count'=>$pos['count']));
				$pos['hash']=cart_getPosHash($p);//Метка версии замороженной позиции
			}
		});
	}else{//Текущий статус не замораживает позиции
		infra_foro($order['basket'],function(&$pos,$prodart){
			if(!$pos['article'])return;
			$pos=array(
				'count'=>$pos['count']
			);
		});
	}

	if($order['status']=='active'){//Сохраняем активную заявку без лишних данных, нужно хронить её номер чтобы другая заявка не заняла
		$order['fixid']=$id;
		unset($order['id']);//У активной заявки нет id
		infra_session_set('user', $order);//Исключение, данные заявки хранятся в user
		$save=array(
			'email'=>infra_session_getEmail(),//Тот пользователь который сделал заявку активной или последний кто с ней работал
			'status'=>'active',
			'time'=>time()
		);
	}else{
		unset($order['fixid']);
		$order['time']=time();
		$order['id']=$id;
		$save=$order;
	}
	
	file_put_contents(ROOT.infra_theme(cart_getPath()).$id.'.json', infra_json_encode($save));

}

function cart_getMyOrders(){
	return infra_once('cart_getMyOrders',function(){
		$myorders=infra_session_get('safe.orders',array());
		$list=array();
		infra_forr($myorders,function($id) use(&$list){
			$order=cart_getGoodOrder($id);
			if(!$order)return;
			if($order['status']=='active')return;
			$list[]=$order;
		});

		usort($list,function($a,$b){
		    return $a['time']<$b['time'];
		});
		return $list;
	});
}
function cart_canI($id,$action=true){//action true совпадёт с любой строчкой
	if(infra_isphp())return true;
	if(infra_session_get('safe.manager'))return true;
	if(!cart_isMy($id))return false;
	$order=cart_getGoodOrder($id);
	if($order['rule']['user']['buttons'][$action])return true;
	return infra_forr($order['rule']['user']['actions'],function($r) use($action){
		if($r['act']==$action)return true;
	});
}
function cart_isMy($id){
	if(!$id)return true;
	$ar=infra_session_get('safe.orders',array());
	return in_array($id,$ar);
}
function cart_initRule(&$order){
	$rules=infra_loadJSON('-cart/rules.json');
	infra_foro($rules['actions'],function(&$act) use($order){
		if($act['link'])$act['link']=infra_template_parse(array($act['link']),$order);
	});
	$order['rule']=$rules['rules'][$order['status']];

	$list=array(&$order['rule']['manager'],&$order['rule']['user']);

	infra_forr($list,function(&$ar) use($rules,&$order){
		/*infra_foro($ar['others'],function($other,$istpl) use(&$order,&$ar){
			$is=infra_template_parse(array($istpl),$order);

			if($is){
				if(isset($other['buttons']))$ar['buttons']=$other['buttons'];
				if(isset($other['actions']))$ar['actions']=$other['actions'];
				return true;
			}	
		});
		*/

		infra_foro($ar['buttons'],function(&$cls,$act) use($rules,&$order,&$ar){
			$index=array_search($act,$ar['actions']);
			if($index!==false){
				array_splice($ar['actions'],$index,1);
			}
			if(!$rules['actions'][$act]){
				$cls=array(
					'cls'=>$cls,
					'act'=>$act
				);
			}else{
				$t=$cls;
				$cls=$rules['actions'][$act];
				$cls['act']=$act;
				$cls['cls']=$t;
			}
			if($cls['omit']){
				$omit=infra_template_parse(array($cls['omit']),$order);
				if($omit)return new infra_Fix('del');
			}
			
		});
		infra_fora($ar['actions'],function(&$act) use($rules,&$order){
			if(!$rules['actions'][$act]){
				$cls=array(
					'act'=>$act
				);
			}else{
				$cls=$rules['actions'][$act];
				$cls['act']=$act;
			}

			if($cls['omit']){
				$omit=infra_template_parse(array($cls['omit']),$order);
				if($omit)return new infra_Fix('del');
				
			}
			$act=$cls;
		});


	});

}
function cart_getPosHash($pos){
	return md5($pos['Цена оптовая'].':'.$pos['Цена розничная']);
}
function cart_getGoodOrder($id=''){
	return infra_once('getGoodOrder',function($id){
		$order=cart_loadOrder($id);
		if(!$order)return false;//Нет заявки с таким $id
		$order['id']=$id;

		cart_initRule($order);
	
		
		$order['email']=trim($order['email']);
		$order['sumopt']=0;
		$order['sumroz']=0;
		$order['count']=0;
		$num=0;

		infra_foro($order['basket'],function(&$pos,$prodart) use(&$order,&$num){
			$count=$pos['count'];//Сохранили значение из корзины
			if($count<1)return new infra_Fix('del');

			if(!$order['rule']['freeze']){
				$pos=cat_getByProdart($prodart);
				if(!$pos)return new infra_Fix('del');
			}else{
				$p=cat_getByProdart($prodart);
				
				if(!$pos['article']){//Такое может быть со старыми заявками... deprcated удалить потом.
					//Значит позиция некорректно заморожена
					$pos=cat_getByProdart($prodart);
					if(!$pos)return new infra_Fix('del');
				}else{
					$hash=cart_getPosHash($p);
					if($pos['hash']!=$hash)$pos['change']=true;//Метка что что-то поменялось в описании позиции.
				}
			}
			
			
			$pos['num']=++$num;
			$pos['count']=$count;
			$order['count']++;
			
			if($pos['Цена оптовая'])$pos['sumopt']=$pos['Цена оптовая']*$pos['count'];
			else $pos['sumopt']=0;
			if($pos['Цена розничная'])$pos['sumroz']=$pos['Цена розничная']*$pos['count'];
			else $pos['sumroz']=0;
			$order['sumopt']+=$pos['sumopt'];
			$order['sumroz']+=$pos['sumroz'];

		});
		$hadpaid=0;//Сумма уже оплаченных заявок
		
		//В заявке сохранён email по нему можно получить пользователя и все его заявки
		//email появляется у активной заявки и потом больше не меняется
		$orders=infra_session_user_get($order['email'],'safe.orders',array());//Получить значение сессии какого-то пользователя

		//Если заявка числится у нескольких пользователей, в safe.orders мы будем смотреть по текущей
		//В общем то что заявка у нескольких пользователей пофигу. 
		//Менеджер отталкиваемся пользователя который перевёл заявку из активного статуса, самый первый именно он попадает в order.email это в saveOrder

		infra_forr($orders,function($id) use(&$hadpaid,$order){
			if($order['id']==$id)return;//Текущую заявку не считаем
			$order=cart_loadOrder($id);
			$rules=infra_loadJSON('-cart/rules.json');
			
			if(!$order['manage']['paid'])return;//Если статус не считается оплаченым выходим
			if(in_array($order['status'],array('canceled','error')))return;//Если статус не считается оплаченым выходим
			if($order['manage']['bankrefused'])return;
			
			//Хотя оплачена alltotal вместе с доставкой
			//if(!$order['total'])return;//У оплаченой заявки обязательно должно быть total оплаченная, без цены доставки.
			//$order['manage']['paid'] вся оплаченная сумма с заявкой, по факту.
			$hadpaid+=$order['manage']['paid'];
		});
		$order['hadpaid']=$hadpaid;
		//sum цена всех товаров
		//total цена всех товаров с учётом цены указанной менеджером, тобишь со скидкой
		//
		$merch=infra_loadJSON('~merchants.json');
		//$order['email']=infra_session_getEmail();
		$order['level']=$merch['level'];
		if($order['email']&&$merch['merchants'][$order['email']]){
			$order['merch']=true;
		}else{
			$order['merch']=false;
		}
		if(!$order['merch']){
			$order['need']=$order['level']-($order['sumopt']+$order['hadpaid']);
			if($order['need']<0)$order['need']=0;
		}else{
			$order['need']=0;
		}
		$order['merchdyn']=!$order['need'];
		if($order['merchdyn']){
			$order['sum']=$order['sumopt'];
			infra_foro($order['basket'],function(&$pos){
				$pos['sum']=$pos['sumopt'];
				$pos['cost']=$pos['Цена оптовая'];
			});
		}else{
			$order['sum']=$order['sumroz'];
			infra_foro($order['basket'],function(&$pos){
				$pos['sum']=$pos['sumroz'];
				$pos['cost']=$pos['Цена розничная'];
			});
		}
		$order['total']=$order['sum'];
		if($order['manage']['summary']){
			$order['manage']['summary']=preg_replace('/\s/','',$order['manage']['summary']);
			$order['total']=$order['manage']['summary'];
		}

		//Стоимость с доставкой
		$order['alltotal']=$order['total'];
		if($order['manage']['deliverycost']){
			$order['manage']['deliverycost']=preg_replace('/\s/','',$order['manage']['deliverycost']);
			$order['alltotal']+=$order['manage']['deliverycost'];
		}
		return $order;
	},array($id));
}
function cart_checkData($str, $type='value'){
	switch($type){
		case 'radio': return !!$str;
		case 'value': return $str&&strlen($str)>1;
		case 'email': return $str&&preg_match('/^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$/',$str);
	}
}
function cart_checkReg($email,$password=false){//Сессия остаётся текущей
	$email=trim(strip_tags($email));
	if(!cart_checkData($email, 'email'))return 'Необходимо указать крректный email';
	$myemail = infra_session_getEmail();
	if(!$myemail){//Значит пользователь не зарегистрирован
		$userData = infra_session_getUser($email);// еще надо проверить есть ли уже такой эмаил
		if($userData['session_id']){
			return 'На указанный email на сайте есть регистрация, необходимо <a onclick="cart.goTop()" href="?office/signin">авторизоваться</a>';
		}else{
			infra_session_setEmail($email);
			if($password)infra_session_setPass($password);
			return cart_mail('user',$email,'signup');
		}
	}
}
function cart_ret($order,$action){
	$rules=infra_loadJSON('-cart/rules.json');
	$rule=$rules['actions'][$action];
	$ans=array(
		'result'=>1,
		'status'=>$order['status'],
		'id'=>$order['id'],
		'msg'=>infra_template_parse(array($rule['result']),$order)
	);
	if(!infra_session_get('dontNofify'))cart_mail('user',$order['email'],$rule['usermail'],$order);
	cart_mail('manager',$order['email'],$rule['mangmail'],$order);
	return infra_ans($ans);
}
function cart_mail($to,$email,$mailroot, $data=array()){
	if(!$email)$email='noreplay@'.$_SERVER['HTTP_HOST'];
	if(!$mailroot)return;//Когда не указаний в конфиге... ничего такого...
	$rules=infra_loadJSON('-cart/rules.json');

	$data['host']=infra_view_getHost();
	$data['path']=infra_view_getRoot(ROOT);
	$data['link']=infra_session_getLink($email);
	$data['email']=$email;
	$data['user']=infra_session_getUser($email);
	$data['time']=time();
	$data["site"]=$data['host'].'/'.$data['path'];

	$subject = infra_template_parse(array($rules['mails'][$mailroot]),$data);
	$body = infra_template_parse('-cart/cart.mail.tpl',$data,$mailroot);
	if($to=='user')return infra_mail_fromAdmin($subject,$email,$body);
	if($to=='manager')return infra_mail_toAdmin($subject,$email,$body);
}
?>