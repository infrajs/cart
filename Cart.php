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
use infrajs\mail\Mail;
use infrajs\config\Config;
use infrajs\path\Path;
use infrajs\event\Event;
use infrajs\excel\Xlsx;
use infrajs\each\Fix;
use infrajs\user\User;
use infrajs\view\View;
use infrajs\lang\Lang;

Event::$classes["Cart"] = function($pos) { 
	return $pos["producer_nick"].$pos["article_nick"].$pos["item_nick"];
};
class Cart {
	public static $conf = [];
	public static function getPath($id = '') 
	{
		if (!$id) return '~auto/.cart/';	
		return '~auto/.cart/'.$id.'.json';
	}
	public static function getMyOrders()
	{
		return Once::func( function () {
			$myorders = Session::get('safe.orders', array());
			
			$list = array();
			for ($i = 0, $l = sizeof($myorders); $i < $l; $i++) {
				$id = $myorders[$i];
				$order = Cart::getGoodOrder($id);
				if (!$order) continue;
				if ($order['status'] == 'active') continue; //WTF?
				$list[] = $order;
			}
			
			usort($list, function ($a, $b) {
			    return $a['time'] < $b['time'];
			});
			
			return $list;
		});
	}
	public static function getByProdart($prodart) {
		$prodart = trim($prodart);
		if (!$prodart) return [];
		$query = explode(" ",$prodart);
		$query = implode("/", $query);
		$data = Load::loadJSON('-showcase/api/pos/'.$query);
		$pos = $data['pos'];
		return $pos;
	}
	public static function getGoodOrder($id = '')
	{
		if (is_array($id)) {
			$order = $id;
			if (empty($order['id'])) {
				$id = null;
			} else {
				$id = $order['id'];
			}
		} else {
			$order = false;
		}
		return Once::func(function &($id) use (&$order) {
			
			if (!$order) $order = Cart::loadOrder($id);

			$r = false;
			if (!$order) return $r;//Нет заявки с таким $id
			$order['id'] = $id;
			$order['rule'] = Cart::getRule($order);


			
			if(empty($order['email']))$order['email'] = '';
			$order['email'] = trim($order['email']);
			$order['sum'] = 0;
			$order['count'] = 0;
			$num = 0;
			Each::foro($order['basket'], function &(&$pos,$prodart) use (&$order,&$num) {
				$r = null;
				if(!isset($pos['count'])) $pos['count'] = 0;
				$count = $pos['count'];//Сохранили значение из корзины
				if (empty($pos['Цена'])) $pos['Цена'] = 0;
				if ($count<1) {
					$r = new Fix('del');
					return $r;
				}
				if (empty($order['rule']['freeze'])) {
					$pos = Cart::getByProdart($prodart);
					if (!$pos) {
						$r = new Fix('del');
						return $r;
					}
				} else {
					$p = Cart::getByProdart($prodart);
					if (empty($pos['article_nick'])) {//Такое может быть со старыми заявками... deprcated удалить потом.
						//Значит позиция некорректно заморожена
						$pos = Cart::getByProdart($prodart);
						if (!$pos) {
							$r = new Fix('del');
							return $r;
						}
					} else {
						$hash = Cart::getPosHash($p);
						if ($pos['hash'] != $hash) $pos['change'] = true;//Метка что что-то поменялось в описании позиции.
					}
				}
				if (empty($pos['Цена'])) $pos['Цена'] = 0;
				
				$pos['num']=++$num;
				$pos['count']=$count;
				$order['count']++;
				$conf = Config::get('cart');
			
				$pos['sum']=$pos['Цена']*$pos['count'];
				
				
				$order['sum']+=$pos['sum'];

				return $r;
			});

			$hadpaid=0;//Сумма уже оплаченных заявок
			
			//В заявке сохранён email по нему можно получить пользователя и все его заявки
			//email появляется у активной заявки и потом больше не меняется
			$orders = Session::user_get($order['email'],'safe.orders',array());//Получить значение сессии какого-то пользователя

			//Если заявка числится у нескольких пользователей, в safe.orders мы будем смотреть по текущей
			//В общем то что заявка у нескольких пользователей пофигу. 
			//Менеджер отталкиваемся пользователя который перевёл заявку из активного статуса, самый первый именно он попадает в order.email это в saveOrder

			Each::forr($orders, function &($id) use (&$hadpaid, $order) {
				$r = null;
				if ($order['id']==$id) return $r;//Текущую заявку не считаем
				$order = Cart::loadOrder($id);
				$rules = Load::loadJSON('-cart/rules.json');
				
				if (empty($order['manage']['paid'])) return $r;//Если статус не считается оплаченым выходим
				if (in_array($order['status'],array('canceled','error'))) return $r;//Если статус не считается оплаченым выходим
				if ($order['manage']['bankrefused']) return $r;
				
				//Хотя оплачена alltotal вместе с доставкой
				//if (!$order['total']) return;//У оплаченой заявки обязательно должно быть total оплаченная, без цены доставки.
				//$order['manage']['paid'] вся оплаченная сумма с заявкой, по факту.
				$hadpaid += $order['manage']['paid'];
				return $r;
			});
			$order['hadpaid']=$hadpaid;
			//sum цена всех товаров
			//total цена всех товаров с учётом цены указанной менеджером, тобишь со скидкой
			
			$conf = Config::get('cart');
			
			//$pos['cost'] = $pos['Цена'];
			
			Each::foro($order['basket'], function &(&$pos) {
				$r = null;
				if (empty($pos['Цена'])) $pos['Цена'] = 0;
				$pos['cost'] = $pos['Цена'];
				return $r;
			});

			$order['total'] = $order['sum'];

			if (!empty($order['coupon'])) {
				$coupon = Load::loadJSON('-cart/coupon?name='.$order['coupon']);
				$order['coupon_data'] = $coupon;
				if ($coupon['result']) {

				
					$order['total'] = 0;

					foreach ($coupon['rows'] as $k => $row) {
						if (isset($coupon['rows'][$k]['Производители'])) {
							$r = explode(',', $coupon['rows'][$k]['Производители']);
							$coupon['rows'][$k]['Производители'] = array_map(function ($v){
								return Path::encode($v);
							}, $r);
						}
						if (isset($coupon['rows'][$k]['Группы'])) {
							$r = explode(',', $coupon['rows'][$k]['Группы']);
							$coupon['rows'][$k]['Группы'] = array_map(function ($v){
								return Path::encode($v);
							}, $r);
						}
					}
					Each::foro($order['basket'], function &(&$pos, $prodart) use (&$coupon, &$order) {
						
						$r = true;

						foreach ($coupon['rows'] as $row) {
							$rr = true;
							if (isset($row['Производители'])) {
								if (!in_array($pos['producer_nick'], $row['Производители'])) {
									$rr = false;
									continue;
								}
							}
							if (isset($row['Группы'])) {
								$rg = false;
								foreach ($pos['path'] as $g) {
									if (in_array($g, $row['Группы'])) {
										$rg = true;	
										break;
									}
								}
								if (!$rg) {
									$rr = false;
									continue;
								}
							}
							if ($rr) break;
						}
						if ($rr) {
							$pos['coupon'] = $row;

						} else {
							$r = false;
						}
						
						if ($r) $r = Event::fire('Cart.coupon', $pos);
						
						if ($r) { //Действует
							$discount = $pos['coupon']['Скидка'];
							$pos['coupcost'] = $pos['Цена'] * (1-$discount);
							$sum = $pos['Цена'] * $pos['count'] * (1-$discount);
							if ($pos['coupcost'] == $pos['Цена']) unset($pos['coupcost']);
						} else {//Не дейстует
							unset($pos['coupon']);
							$sum = $pos['Цена'] * $pos['count'];
						}
						$order['total'] += $sum;
						$r = null; return $r;
					});
					
				}
				
				//if ($coupon['result']) {
				//$fncost = Template::$scope['~cost'];
			}
			if (!empty($order['manage']['summary'])) {
				$order['manage']['summary'] = preg_replace('/\s/','',$order['manage']['summary']);
				$order['total']=$order['manage']['summary'];
			}
			//Стоимость с доставкой
			$order['alltotal']=$order['total'];
			if (!empty($order['manage']['deliverycost'])) {
				$order['manage']['deliverycost'] = preg_replace('/\s/','',$order['manage']['deliverycost']);
				$order['alltotal']+=$order['manage']['deliverycost'];
			}
			return $order;
		}, array($id));
	}
	public static function sync($place, $orderid) {
		$order = Cart::loadOrder($orderid);
		$rule = Cart::getRule($order);
		if (($place == 'admin' && Session::get('safe.manager')) || !empty($rule['edit'][$place])) { //Place - orders admin wholesale

			$r = Cart::mergeOrder($order, $place);
			//if ($r) 
			Cart::saveOrder($order, $place);
		} else {
			$r = Cart::mergeOrder($order, $place, true);
			//if ($r) 
			Cart::saveOrder($order, $place);
		}
	}
	public static function isMy($id) {
		if (!$id) return true;
		$ar = Session::get('safe.orders', array());
		return in_array($id, $ar);
	}
	public static function canI($id, $action = true) { //action true совпадёт с любой строчкой
		if (!$id) return true;
		
		//if (Load::isphp()) return true;
		if (Session::get('safe.manager')) return true;
		if (!Cart::isMy($id)) return false;
		$order = Cart::loadOrder($id);
		if ($action === true) return true;
		$rule = Cart::getRule($order);
		return Each::exec($rule['user']['actions'], function &($a) use ($action) {
			$r = null;
			if ($a['act'] == $action) $r = true;
			return $r;
		});
	}
	public static function &loadOrder($id = '')
	{
		//Результат этой фукции можно сохранять в файл она не добавляет лишних данных, но оптимизирует имеющиеся
		return Once::func( function &($id) {
			if ($id) {
				$order = Load::loadJSON(Cart::getPath($id));
				$r = false;
				if (!$order) return $r;//Нет такой заявки с таким id
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
				$rules = Cart::getRule();
				if (empty($rules['rules'][$order['status']])) $order['status'] = $rules['def'];
			} else {
				$order = Session::get('orders.my', array());
				Each::foro($order, function &(&$val, $name) {
					$r = null;
					if (is_string($val)) $val = trim($val);
					return $r;
				});
				/*//По идеи в сессии хранится email и он уже там есть, как и любые другие поля.
				$email = Session::getEmail();//Это единственное место где в заявку добавляется email
				if (isset($order['email']) && $email && $email != $order['email']) {
					$user = Session::getUser($order['email']);
					if ($user) { //Пользователь с указанным уже есть и это не текущий пользователь
						if (Session::get('safe.manager')) {

						} else {
							$r = Cart::lang('To your email on the website there is a registration, you need to <a href=\'/user/signin\'>login</a>');
							return $r;
						}
					}
				}*/
				$order['status'] = 'active';
			}
			if (empty($order['manage'])) $order['manage'] = array();
			return $order;
		}, array($id));
	}
	public static function getRule($order = false) {
		$rules = Load::loadJSON('-cart/rules.json');
		if (!$order) return $rules;

		foreach ($rules as $i => $act) {
			if (!empty($rules[$i]['link'])) $rules[$i]['link'] = Template::parse(array($rules[$i]['link']), $order);
		}
		$rule = $rules['rules'][$order['status']];
		$list = array(&$rule['manager'], &$rule['user']);

		Each::exec($list, function &(&$ar) use ($rules, &$order) {
			$r = null;

			Each::foro($ar['buttons'], function &(&$cls,$act) use($rules,&$order,&$ar) {
				$r = null;
				/*$index=array_search($act, $ar['actions']);
				if ($index!==false) {
					array_splice($ar['actions'],$index,1);
				}*/

				if (!$rules['actions'][$act]) {
					$cls = array(
						'cls' => $cls,
						'act' => $act
					);
				} else {
					$t = $cls;
					$cls = $rules['actions'][$act];
					$cls['act'] = $act;
					$cls['cls'] = $t;
				}
				if (!empty($cls['omit'])) {
					$omit=Template::parse(array($cls['omit']),$order);
					if ($omit) {
						$fix = new Fix('del');
						return $fix;
					}
				}
				return $r;
			});
			
			if ($ar['buttons']) { //Все кнопки добавим в список
				$buttons = array_keys($ar['buttons']);
				$ar['actions'] = array_merge($ar['actions'],$buttons);

				$ar['actions'] = array_unique($ar['actions']);
				$ar['actions'] = array_values($ar['actions']);
			}

			Each::exec($ar['actions'], function &(&$act) use ($rules, &$order) {
				

				if (!$rules['actions'][$act]) {
					$cls=array(
						'act'=>$act
					);
				} else {
					$cls=$rules['actions'][$act];
					$cls['act']=$act;
				}

				if (!empty($cls['omit'])) {
					$omit=Template::parse(array($cls['omit']),$order);
					if ($omit) {
						$r = new Fix('del');
						return $r;
					}
					
				}
				$act = $cls;
				return $r;
			});
			return $r;
		});
		return $rule;
	}
	
	
	public static function mail($to, $email, $mailroot, $data = array()) {
		if (!$email) $email='noreplay@'.$_SERVER['HTTP_HOST'];
		if (!$mailroot) return;//Когда не указаний в конфиге... ничего такого...
		$rules = Load::loadJSON('-cart/rules.json');

		$data['host'] = View::getHost();
		$data['link'] = Session::getLink($email);
		$data['email'] = $email;
		$data['user'] = Session::getUser($email);
		$data['time'] = time();
		$data["site"] = $data['host'];

		$subject = Template::parse(array($rules['mails'][$mailroot]),$data);
		$body = Template::parse('-cart/cart.mail.tpl',$data,$mailroot);

		//Mail::toSupport($subject.' - копия для поддержки', $email, $body);

		if ($to=='user') {
			return Mail::html($subject, '<pre>'.$body.'</pre>', true, $email);  //from, to
			//return Mail::fromAdmin($subject, $email, $body);
		}
		if ($to=='manager') {
			return Mail::html($subject, '<pre>'.$body.'</pre>', $email, true); //from, to
			//return Mail::toAdmin($subject,$email,$body);
		}
	}
	public static function mergeOrder(&$order, $place, $safe = false) {
		if (empty($order['id'])) return;

		if (!$safe) {
			$actualdata = Session::get([$place, $order['id']], array());
			foreach ($actualdata as $name => $val) {
				if (!is_string($val)) continue;
				$actualdata[$name] = mb_substr(trim(strip_tags($val)), 0, 200);
			}
		} else { //Когда нельзя редактировать... если хочется то можно сохранить комент
			$val = Session::get([$place, $order['id'], 'comment'], '');
			$actualdata['comment'] = mb_substr(trim(strip_tags($val)), 0, 20000);
		}
		if (!Session::get('safe.manager') || $place != 'admin') {
			unset($actualdata['manage']); //Только админ на странице admin может менять manage
		}
		if (!$actualdata) return false;

		
		foreach (['manage','basket','transport','pay'] as $name) {
			if (empty($actualdata[$name])) continue;
			if (empty($order[$name])) continue;
			$actualdata[$name] = array_merge($order[$name], $actualdata[$name]);
		}
		$order = array_merge($order, $actualdata);
		return true;
	}
	public static function catchOrder($order, $email = false) {
		$id = $order['id'];
		if (!$email) {
			$myorders = Session::get(['safe','orders'], array());
			$myorders[] = $id;
			Session::set(['safe','orders'], array_unique($myorders));
		} else {
			$user = Session::getUser($order['email']);
			if (!$user) $user = Session::createUser($order['email']);
			
			$myorders = Session::user_get($order['email'],'safe.orders',array());
			$myorders[] = $id;
			Session::user_set($order['email'], ['safe','orders'], array_unique($myorders));
		}
			
	}
	public static function saveOrder(&$order, $place = false) {
		if (!empty($order['id'])) $id = $order['id'];
		else $id = false;

		if (!$id) {
			if (!empty($order['fixid'])) {
				
				$id = $order['fixid'];//Заявка уже есть в списке моих заявок

			} else if ($order['status'] == 'active') {
				//Сохранить активную заявку
				//Активная заявка и нет fixid не сохраняем в файл
				Session::set('orders.my', $order);//Исключение, данные заявки
				return;
			} else {
				$id = time();
				$src = Cart::getPath($id);
				while (Path::theme($src)) {
					$id++;
					$src = Cart::getPath($id);
				}
			}
			$order['id'] = $id;
			//Добавляем в заявки пользователя
			Cart::catchOrder($order);
		} else {
			if ($place) Session::set([$place, $id]); //Удаляем автосохранение
			$src = Cart::getPath($id);
		}
		
		$myemail = Session::getEmail();
		if ($myemail != $order['email']) {
			Cart::catchOrder($order, $order['email']);
		}


		$rules = Load::loadJSON('-cart/rules.json');
		if (!empty($rules['rules'][$order['status']]['freeze'])) {//Текущий статус должен замораживать позиции
			Each::foro($order['basket'], function &(&$pos, $prodart) {
				$r = null;
				if (!empty($pos['article'])) return $r;
				$p=Cart::getByProdart($prodart);
				if ($p) {//Товар найден в каталоге
					$pos = array_merge($p,array('count'=>$pos['count']));
					unset($pos['items']);
					unset($pos['itemrows']);
					$pos['hash'] = Cart::getPosHash($p);//Метка версии замороженной позиции
				}
				return $r;
			});
		} else {//Текущий статус не замораживает позиции
			Each::foro($order['basket'], function &(&$pos,$prodart) {
				$r = null;
				if (empty($pos['article'])) return $r;
				$pos = array(
					'count'=>$pos['count']
				);
				return $r;
			});
		}

		if ($order['status'] == 'active') { 
			//Сохраняем активную заявку без лишних данных, нужно хронить её номер чтобы другая заявка не заняла
			$order['fixid'] = $id;
			unset($order['id']);//У активной заявки нет id
			$oldactive = Session::get('orders.my');
			if (!empty($oldactive['fixid'])) { //Освобождаем старую активную заявку
				unlink(Path::resolve(Cart::getPath($oldactive['fixid'])));
			}
			
			//unset($order['manage']);//Сообщение менеджера удаляется
			if (empty($order['phone'])) $order['phone'] = '';
			if (empty($order['name'])) $order['name'] = '';

			Session::set('orders.my', $order);//Исключение, данные заявки
			

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
		if(!isset($pos['Цена'])) $pos['Цена'] = '';
		else return md5($pos['Цена']);
	}
	public static function lang($str = null)
	{
		if (is_null($str)) return Lang::name('cart');
		return Lang::str('cart',$str);
	}
	public static function ret($ans, $action) {
		$rules = Load::loadJSON('-cart/rules.json');
		$order = $ans['order'];
		$rule = $rules['actions'][$action];
		/*if ($ans['place'] != 'admin'  && !empty($order['email'])) { //Админ сам решает когда, что отправлять
			if (!empty($rule['usermail'])) {
				Cart::mail('user', $order['email'], $rule['usermail'], $ans['order']);
			}
			if (!empty($rule['mangmail'])) {
				Cart::mail('manager', $order['email'], $rule['mangmail'], $order);
			}
		}*/
		if (!empty($order['email'])) {
			//Клиент отправляет письма менеджеру и себе
			//Менеджер только клиенту отправляет письма
			if (!empty($rule['usermail'])) {
				Cart::mail('user', $order['email'], $rule['usermail'], $ans['order']);
			}

			if ($ans['place'] == 'orders') {
				if (!empty($rule['mangmail'])) {
					Cart::mail('manager', $order['email'], $rule['mangmail'], $order);
				}
			}
		}
		
		return Ans::ret($ans);
	}
}
