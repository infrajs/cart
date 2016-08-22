<?php
	@define('ROOT','../../../');
	require_once(ROOT.'infra/plugins/infra/infra.php');
	infra_require('*cart/cart.inc.php');
	infra_cache_no();
	if($_REQUEST['submit']){
		$ans=array('msg'=>'','result'=>0);
		
		if(infra_admin()&&infra_session_getEmail()){
			if($_REQUEST['IAmManager'])
				infra_session_set('safe.manager',true);
			else
				infra_session_set('safe.manager',false);
			return infra_echo($ans,'ok',1);
		}else{
			return infra_echo($ans,'У вас не достаточно прав!',0);
		}
	}



	$orders=cart_getMyOrders();
	$order=cart_getGoodOrder();
	$ans['order']=$order;
	

	$list=array();
	infra_forr($orders,function($order) use(&$list){
		$status=$order['status'];
		if(!$list[$status])$list[$status]=array();
		$list[$status][]=array(
			'id'=>$order['id'],
			'time'=>$order['time']
		);
	});
	$ans['rules']=infra_loadJSON('*cart/rules.json');
	$ans['list']=$list;
	$ans['admin']=infra_admin();
	$ans['email']=infra_session_getEmail();
	$ans['manager']=infra_session_get('safe.manager');
	
	return infra_ret($ans);
?>