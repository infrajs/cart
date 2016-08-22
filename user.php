<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
infra_require('*cart/cart.inc.php');
infra_cache_no();
$ans=array(
	'manager'=>infra_session_get('safe.manager'),
	'email'=>infra_session_getEmail()
);
return infra_ans($ans);
?>