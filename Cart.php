<?php
namespace infrajs\cart;
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\access\Access;
use infrajs\session\Session;
use infrajs\once\Once;
use infrajs\load\Load;
use infrajs\template\Template;
use infrajs\each\Each;
use infrajs\catalog\Catalog;
use infrajs\mail\Mail;
use infrajs\config\Config;
use infrajs\path\Path;
use infrajs\excel\Xlsx;
use infrajs\each\Fix;
use infrajs\user\User;
use infrajs\view\View;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}
class Cart {
	public static function getPath($id = '') 
	{
		if (!$id) return '~.cart/';	
		return '~.cart/'.$id.'.json';
	}
	public static function getMyOrders()
	{
		return Once::exec(__FILE__.'-getMyOrders', function () {
			$myorders = Session::get('safe.orders', array());
			
			$list = array();
			for ($i = 0, $l = sizeof($myorders); $i < $l; $i++) {
				$id = $myorders[$i];
				$order = Cart::getGoodOrder($id);
				if (!$order) continue;
				if ($order['status'] == 'active') continue; //WTF?
				$list[] = $order;
			}
			
			usort($list, function ($a,$b) {
			    return $a['time'] < $b['time'];
			});
			
			return $list;
		});
	}
	public static function getByProdart($prodart) {
		$data = Catalog::init();
		$pos = Xlsx::runPoss($data, function ($pos) use ($prodart) {
		    $realprodart=$pos['producer'].' '.$pos['article'];
		    if ($realprodart == $prodart) return $pos;
		});
		return $pos;
	}
	public static function getGoodOrder($id = '', $re = false)
	{
		if (is_array($id)) {
			$order = $id;
			$id = $order['id'];
		} else {
			$order = false;
		}

		return Once::exec(__FILE__.'-getGoodOrder', function &($id, $re) use (&$order) {
			
			if (!$order) $order = Cart::loadOrder($id, $re);
			if (!$order) return false;//Нет заявки с таким $id
			$order['id'] = $id;
			$order['rule'] = Cart::getRule($order);
			
			$order['email'] = trim($order['email']);
			$order['sumopt'] = 0;
			$order['sumroz'] = 0;
			$order['count'] = 0;
			$num=0;

			Each::foro($order['basket'],function(&$pos,$prodart) use(&$order,&$num) {
				$count=$pos['count'];//Сохранили значение из корзины
				if ($count<1) return new infra_Fix('del');

				if (!$order['rule']['freeze']) {
					$pos=Cart::getByProdart($prodart);
					if (!$pos) return new infra_Fix('del');
				} else {
					$p = Cart::getByProdart($prodart);
					
					if (!$pos['article']) {//Такое может быть со старыми заявками... deprcated удалить потом.
						//Значит позиция некорректно заморожена
						$pos=Cart::getByProdart($prodart);
						if (!$pos) return new infra_Fix('del');
					} else {
						$hash = Cart::getPosHash($p);
						if ($pos['hash'] != $hash) $pos['change'] = true;//Метка что что-то поменялось в описании позиции.
					}
				}
				
				
				$pos['num']=++$num;
				$pos['count']=$count;
				$order['count']++;
				$conf = Config::get('cart');
				if ($conf['opt']) {
					if ($pos['Цена оптовая']) $pos['sumopt']=$pos['Цена оптовая']*$pos['count'];
					else $pos['sumopt']=0;
					if ($pos['Цена розничная']) $pos['sumroz']=$pos['Цена розничная']*$pos['count'];
					else $pos['sumroz']=0;
				} else {
					$pos['sumroz']=$pos['Цена']*$pos['count'];
				}
				$order['sumopt']+=$pos['sumopt'];
				$order['sumroz']+=$pos['sumroz'];

			});
			$hadpaid=0;//Сумма уже оплаченных заявок
			
			//В заявке сохранён email по нему можно получить пользователя и все его заявки
			//email появляется у активной заявки и потом больше не меняется
			$orders=Session::user_get($order['email'],'safe.orders',array());//Получить значение сессии какого-то пользователя

			//Если заявка числится у нескольких пользователей, в safe.orders мы будем смотреть по текущей
			//В общем то что заявка у нескольких пользователей пофигу. 
			//Менеджер отталкиваемся пользователя который перевёл заявку из активного статуса, самый первый именно он попадает в order.email это в saveOrder

			Each::forr($orders, function ($id) use (&$hadpaid, $order) {
				if ($order['id']==$id) return;//Текущую заявку не считаем
				$order=Cart::loadOrder($id);
				$rules=Load::loadJSON('-cart/rules.json');
				
				if (!$order['manage']['paid']) return;//Если статус не считается оплаченым выходим
				if (in_array($order['status'],array('canceled','error'))) return;//Если статус не считается оплаченым выходим
				if ($order['manage']['bankrefused']) return;
				
				//Хотя оплачена alltotal вместе с доставкой
				//if (!$order['total']) return;//У оплаченой заявки обязательно должно быть total оплаченная, без цены доставки.
				//$order['manage']['paid'] вся оплаченная сумма с заявкой, по факту.
				$hadpaid+=$order['manage']['paid'];
			});
			$order['hadpaid']=$hadpaid;
			//sum цена всех товаров
			//total цена всех товаров с учётом цены указанной менеджером, тобишь со скидкой
			//
			$merch=Load::loadJSON('~merchants.json');
			//$order['email']=Session::getEmail();
			$order['level']=$merch['level'];
			if ($order['email']&&$merch['merchants'][$order['email']]) {
				$order['merch']=true;
			} else {
				$order['merch']=false;
			}
			if (!$order['merch']) {
				$order['need']=$order['level']-($order['sumopt']+$order['hadpaid']);
				if ($order['need']<0)$order['need']=0;
			} else {
				$order['need']=0;
			}
			if ($conf['opt']) {
				$order['merchdyn']=!$order['need'];
				if ($order['merchdyn']) {
					$order['sum']=$order['sumopt'];
					Each::foro($order['basket'],function(&$pos) {
						$pos['sum']=$pos['sumopt'];
						$pos['cost']=$pos['Цена оптовая'];
					});
				} else {
					$order['sum']=$order['sumroz'];
					Each::foro($order['basket'],function(&$pos) {
						$pos['sum']=$pos['sumroz'];
						$pos['cost']=$pos['Цена розничная'];
					});
				}
			} else {
				$pos['cost'] = $pos['Цена'];
				$order['sum'] = $order['sumroz'];
				Each::foro($order['basket'],function(&$pos) {
						$pos['sum']=$pos['sumroz'];
						$pos['cost']=$pos['Цена'];
					});
			}
			$order['total']=$order['sum'];
			if ($order['manage']['summary']) {
				$order['manage']['summary']=preg_replace('/\s/','',$order['manage']['summary']);
				$order['total']=$order['manage']['summary'];
			}

			//Стоимость с доставкой
			$order['alltotal']=$order['total'];
			if ($order['manage']['deliverycost']) {
				$order['manage']['deliverycost']=preg_replace('/\s/','',$order['manage']['deliverycost']);
				$order['alltotal']+=$order['manage']['deliverycost'];
			}
			return $order;
		}, array($id), $re);
	}
	public static function sync($place, $orderid) {
		$order = Cart::loadOrder($orderid);
		$rule = Cart::getRule($order);
		if (Session::get('safe.manager') || $rule['edit'][$place]) { //Place - orders admin wholesale
			$r = Cart::mergeOrder($order, $place);
			if ($r) Cart::saveOrder($order, $place);
		}
	}
	public static function isMy($id) {
		if (!$id) return true;
		$ar = Session::get('safe.orders', array());
		return in_array($id, $ar);
	}
	public static function canI($id, $action = true) { //action true совпадёт с любой строчкой
		if (!$id) return true;
		if (Load::isphp()) return true;
		if (Session::get('safe.manager')) return true;
		if (!Cart::isMy($id)) return false;
		$order = Cart::loadOrder($id);
		if ($action === true) return true;
		$rule = Cart::getRule($order);
		if ($rule['user']['buttons'][$action]) return true;
		return Each::exec($rule['user']['actions'],function($r) use($action) {
			if ($r['act'] == $action) return true;
		});
	}
	public static function &loadOrder($id = '', $re = false)
	{
		//Результат этой фукции можно сохранять в файл она не добавляет лишних данных, но оптимизирует имеющиеся
		return Once::exec(__FILE__.'-loadOrder', function &($id) {
			if ($id) {
				$order = Load::loadJSON(Cart::getPath($id));

				if (!$order) return false;//Нет такой заявки с таким id
				//$email=Session::getEmail();
				

				//У хранящейся Активной заявки есть id, но если мы по id обращаемся значит не нужно применять ту что в сессии user
				//if ($order['status']=='active') {
				//	if ($order['email']==$email) {
				//		return Cart::loadOrder();
				//	}
				//}
				//Применили последний автоsave
				//С какого места вызывали и чью сессию применять
				
				//Права доступа тут не проверяются
				//Менеджер Отредактировал заявку в admin перешёл в orders увидел тоже самое

				//Если я менеджер сессия применяется всегда.
				//Если не менеджер то только если разрешено в месте orders  
				$order['id'] = $id;
			} else {
				$order = Session::get('orders.my', array());
				Each::foro($order, function (&$val, $name) {
					if (is_string($val)) $val = trim($val);
				});//По идеи в сессии хранится email и он уже там есть, как и любые другие поля.
				$email = Session::getEmail();//Это единственное место где в заявку добавляется email
				if ($email)$order['email'] = $email;//Когда нет регистрации email берём из формы autosave
				$order['status'] = 'active';
			}
			if (!$order['manage']) $order['manage'] = array();
			return $order;
		}, array($id), $re);
	}
	public static function getRule($order) {
		$rules = Load::loadJSON('-cart/rules.json');
		foreach ($rules as $i => $act) {
			if ($rules[$i]['link']) $rules[$i]['link'] = Template::parse(array($rules[$i]['link']), $order);
		}
		$rule = $rules['rules'][$order['status']];

		$list = array(&$rule['manager'], &$rule['user']);

		Each::forr($list,function(&$ar) use ($rules, &$order) {
			/*Each::foro($ar['others'],function($other,$istpl) use(&$order,&$ar) {
				$is=Template::parse(array($istpl),$order);

				if ($is) {
					if (isset($other['buttons']))$ar['buttons']=$other['buttons'];
					if (isset($other['actions']))$ar['actions']=$other['actions'];
					return true;
				}	
			});
			*/

			Each::foro($ar['buttons'],function(&$cls,$act) use($rules,&$order,&$ar) {
				$index=array_search($act, $ar['actions']);
				if ($index!==false) {
					array_splice($ar['actions'],$index,1);
				}
				if (!$rules['actions'][$act]) {
					$cls=array(
						'cls'=>$cls,
						'act'=>$act
					);
				} else {
					$t=$cls;
					$cls=$rules['actions'][$act];
					$cls['act']=$act;
					$cls['cls']=$t;
				}
				if ($cls['omit']) {
					$omit=Template::parse(array($cls['omit']),$order);
					if ($omit) return new infra_Fix('del');
				}
				
			});
			Each::fora($ar['actions'], function (&$act) use ($rules, &$order) {
				if (!$rules['actions'][$act]) {
					$cls=array(
						'act'=>$act
					);
				} else {
					$cls=$rules['actions'][$act];
					$cls['act']=$act;
				}

				if ($cls['omit']) {
					$omit=Template::parse(array($cls['omit']),$order);
					if ($omit) return new Fix('del');
					
				}
				$act=$cls;
			});


		});
		return $rule;
	}
	
	
	public static function mail($to,$email,$mailroot, $data = array()) {
		if (!$email) $email='noreplay@'.$_SERVER['HTTP_HOST'];
		if (!$mailroot) return;//Когда не указаний в конфиге... ничего такого...
		$rules = Load::loadJSON('-cart/rules.json');

		$data['host'] = View::getHost();
		$data['path'] = View::getRoot();
		$data['link'] = Session::getLink($email);
		$data['email'] = $email;
		$data['user'] = Session::getUser($email);
		$data['time'] = time();
		$data["site"] = $data['host'].'/'.$data['path'];

		$subject = Template::parse(array($rules['mails'][$mailroot]),$data);
		$body = Template::parse('-cart/cart.mail.tpl',$data,$mailroot);
		if ($to=='user') return Mail::fromAdmin($subject,$email,$body);
		if ($to=='manager') return Mail::toAdmin($subject,$email,$body);
	}
	public static function mergeOrder(&$order, $place) {
		if (!$order['id']) return;
		$actualdata = Session::get([$place, $order['id']], array());
		foreach ($actualdata as $name => $val) {
			if (!is_string($val)) continue;
			$actualdata[$name] = trim(strip_tags($val));
		}
		if (!Session::get('safe.manager') || $place != 'admin') {
			unset($actualdata['manage']); //Только админ на странице admin может менять manage
		}
		if (!$actualdata) return false;
		if ($actualdata['manage'] && $order['manage']) $actualdata['manage'] = array_merge($order['manage'], $actualdata['manage']);
		if ($actualdata['basket'] && $order['basket']) $actualdata['basket'] = array_merge($order['basket'], $actualdata['basket']);
		$order = array_merge($order, $actualdata);
		return true;
	}
	public static function saveOrder(&$order, $place = false) {
		$id = $order['id'];

		if ($place) Session::set([$place, $id]);

		if (!$id) {
			if ($order['fixid']) {
				$id = $order['fixid'];//Заявка уже есть в списке моих заявок
			} else {
				$id = time();
				$src = Cart::getPath($id);
				while( Path::theme($src)) {
					$id++;
					$src=Cart::getPath($id);
				}
				$myorders = Session::get(['safe','orders'], array());
				$myorders[] = $id;
				$myorders = array_values($myorders);//depricated fix old errors in session
				Session::set(['safe','orders'], $myorders);
			}
		} else {
			if ($place) {
				$src = Cart::getPath($id);
				Session::set($place.$id);
			}
		}
		$rules = Load::loadJSON('-cart/rules.json');
		if ($rules['rules'][$order['status']]['freeze']) {//Текущий статус должен замораживать позиции
			Each::foro($order['basket'], function (&$pos, $prodart) {
				if ($pos['article']) return;
				$p=Cart::getByProdart($prodart);
				if ($p) {//Товар найден в каталоге
					$pos = array_merge($p,array('count'=>$pos['count']));
					$pos['hash'] = Cart::getPosHash($p);//Метка версии замороженной позиции
				}
			});
		} else {//Текущий статус не замораживает позиции
			Each::foro($order['basket'], function (&$pos,$prodart) {
				if (!$pos['article']) return;
				$pos = array(
					'count'=>$pos['count']
				);
			});
		}

		if ($order['status'] == 'active') {//Сохраняем активную заявку без лишних данных, нужно хронить её номер чтобы другая заявка не заняла
			$order['fixid'] = $id;
			unset($order['id']);//У активной заявки нет id
			$oldactive = Session::get('orders.my');
			if ($oldactive['fixid']) { //Освобождаем старую активную заявку
				unlink(Path::resolve(Cart::getPath($oldactive['fixid'])));

			}
			Session::set('orders.my', $order);//Исключение, данные заявки хранятся в user
			$save = array(
				'email' => Session::getEmail(),//Тот пользователь который сделал заявку активной или последний кто с ней работал
				'name' => $order['name'],
				'phone' => $order['phone'],
				'status' => 'active',
				'time' => time()
			);
		} else {
			unset($order['fixid']);
			$order['time'] = time();
			$order['id'] = $id;
			$save = $order;
		}
		file_put_contents(Path::resolve((Cart::getPath()).$id.'.json'), Load::json_encode($save));
	}
	public static function getPosHash($pos) {
		$conf = Config::get('cart');
		if ($conf['opt']) return md5($pos['Цена оптовая'].':'.$pos['Цена розничная']);
		else return md5($pos['Цена']);
	}
	public static function ret($ans, $action) {
		$rules = Load::loadJSON('-cart/rules.json');
		$rule = $rules['actions'][$action];
		if (!Session::get('dontNofify') && $rule['usermail']) {
			Cart::mail('user', $order['email'], $rule['usermail'], $ans['order']);
		}
		if ($rule['mangmail']) {
			Cart::mail('manager', $order['email'], $rule['mangmail'], $order);
		}
		return Ans::ret($ans);
	}
}
