<?php
use infrajs\path\Path;
use infrajs\event\Event;
use infrajs\user\User;
use infrajs\cart\Cart;
use infrajs\db\Db;

Path::req('vendor/infrajs/user/infra.php');


Event::handler('User.merge', function ($user) {
	$old_user_id = $user['user_id']; 
	$new_user_id = $user['to']['user_id'];	
	//Во всех таблицах юзеров надо подменить
	//Скопировать все заявки. Если получилось 2 активных, то их объединить.
	//Может получиться что заявка уже его и получиться дубль... по этому делаем поштучно
	Db::start();
	$order_ids = Db::fetchto('SELECT order_id, active from cart_userorders where user_id = :user_id','order_id', [
		':user_id' => $old_user_id
	]);
	foreach($order_ids as $old_order_id => $row) {
		$res = Db::fetch('SELECT order_id, active from cart_userorders where user_id = :user_id and order_id = :order_id',[
			':user_id' => $new_user_id,
			':order_id' => $old_order_id
		]);
		if ($res) {
			//Заказ уже есть у нового пользователя, надо просто удалить запись о старом владельце
			Db::exec('DELETE FROM cart_userorders WHERE order_id = :order_id and user_id = :user_id',[
				':user_id' => $old_user_id,
				':order_id' => $old_order_id
			]);
			if ($row['active'] && !$res['active']) { //У старого пользователя эта заявка была активной, а у нового нет
				Cart::resetUserActive($new_user_id);
				Cart::setActive($old_order_id, $new_user_id); //Сделали её активной и у нового пользователя
			}
		} else {
			//У нового пользователя нет этого заказа
			$active_order_id = Cart::getActiveOrderId($new_user_id);
			
			
			if ($row['active'] && $active_order_id) {
				//Сейчас у пользователя 2 активных заказа
				//Новые данные $old_order_id (ещё не его)
				//Правильный $active_order_id - оставляем тот который уже был у него на аккаунте
				//Но добавляем в $active_order_id новые данные

				//Надо замёржить $old_order_id в $active_order_id
				$old_order = Cart::getById($old_order_id, true);
				//$active_order = Cart::getById($active_order_id)

				//Запись о старом владельце удаляем
				Db::exec('DELETE FROM cart_userorders WHERE order_id = :order_id and user_id = :user_id',[
					':user_id' => $old_user_id,
					':order_id' => $old_order_id
				]);

				
				$fields = ['name','phone','email','address','zip', 'city_id', 'comment', 'callback', 'coupon', 'coupondata', 'transport','dateedit'];
				$strfields = implode(', ', $fields);
				$old_order_data = Db::fetch("SELECT $strfields
					FROM cart_orders
					WHERE order_id = :old_order_id
				", [
					':old_order_id' => $old_order_id
				]);
				//Если в старом значение есть, то оно приоритетней
				foreach($fields as $field) {
					if (!$old_order_data[$field]) continue; //В старом заказе не указано, пропускам
					//Иначе в новом заказе будут новые данные
					$sql = "UPDATE cart_orders
						SET $field = :field
						WHERE order_id = :active_order_id
					";
					Db::exec($sql, [
						':active_order_id' => $active_order_id,
						':field' => $old_order_data[$field]
					]);
				}
				

				//Бежим по старой карзине и смотрим если такая позиция есть, то заменяем количество, если нет то меняем order_id
				foreach ($old_order['basket'] as $pos) {
					$position_id = Db::col('SELECT position_id FROM cart_basket 
						WHERE order_id = :order_id and catkit = :catkit and item_num = :item_num 
						and article_nick = :article_nick
						and producer_nick = :producer_nick', [
						':order_id' => $active_order_id,
						':article_nick' => $pos['article_nick'],
						':producer_nick' => $pos['producer_nick'],
						':item_num' => $pos['item_num'],
						':catkit' => $pos['catkit']
					]);

					if ($position_id) { //Такая позиция есть в актуальном заказе
						Db::exec('UPDATE cart_basket
							SET count = :count, dateedit = now()
							WHERE position_id = :position_id
						', [
							':position_id' => $position_id,
							':count' => $pos['count']
						]);
						//sum, discount, cost, transports меняются при пересчёте
					} else {
						//Переместили позицию в другой заказ
						Db::exec('UPDATE cart_basket
							SET order_id = :active_order_id
							WHERE position_id = :position_id
						', [
							':position_id' => $pos['position_id'],
							':active_order_id' => $active_order_id
						]);
					}
				}
				Db::exec('DELETE FROM cart_orders WHERE order_id = :old_order_id', [
					':old_order_id' => $old_order_id
				]);
				Cart::recalc($active_order_id);
			} else {
				//Если заказ не активный, просто поменяли пользователя
				//Если у нового пользователя активного заказа нет, теперь будет
				Db::exec('UPDATE cart_userorders
					SET user_id = :new_user_id
					WHERE order_id = :order_id and user_id = :old_user_id
				',[
					':old_user_id' => $old_user_id,
					':new_user_id' => $new_user_id,
					':order_id' => $old_order_id
				]);	
			}
		}
	}
	Cart::$once = [];
	Db::commit();
	

});