<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\load\Load;

use infrajs\mail\Mail;
use infrajs\db\Db;
use akiyatkin\showcase\Showcase;
use infrajs\path\Path;

// Обработка actions
if ($action == 'check') {
    if (!Cart::setStatus($order, 'check')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

    $ouser['order'] = $order;
    if (!$silence) {
        if ($place == 'orders') {
            Cart::mailtoadmin($ouser, $lang, 'AdmOrderToCheck');
        }
        Cart::mail($ouser, $lang, 'orderToCheck');
    }

    //После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
    $r = Cart::resetActive($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

    $worder = Cart::getWaitOrder($ouser);
    if ($worder) {
        $r = Cart::setActive($worder, $ouser);
        if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    }

    return Cart::ret($ans, $lang, 'CR025.a' . __LINE__);
} elseif ($action == 'setcallback') {
    $callback = Ans::REQ('callback', ['yes', 'no', ''], null);
    if (is_null($callback)) return Cart::fail($ans, $lang, 'callback.a' . __LINE__);
    $r = Cart::setCallback($order, $callback);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'years') {
    $years = Cart::getYears();
    $ans['years'] = $years;
    return Cart::ret($ans);
} elseif ($action == 'meta') {

    $ans['meta'] = Cart::getJsMeta($meta, $lang);
    return Cart::ret($ans);
} elseif ($action == 'complete') {
    if (!Cart::setStatus($order, 'complete')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    //После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
    $r = Cart::resetActive($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans, $lang, 'CR040.a' . __LINE__);
} elseif ($action == 'setcommentmanager') {
    $commentmanager = Ans::REQ('commentmanager', 'string', '');
    if (!$commentmanager) return Cart::fail($ans, $lang, 'CR063.a' . __LINE__);
    $r = Cart::setCommentManager($order, $commentmanager);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a5');
    return Cart::ret($ans);
} elseif ($action == 'email') {
    $commentmanager = Ans::REQ('commentmanager', 'string', '');
    if (!$commentmanager) return Cart::fail($ans, $lang, 'CR063.a' . __LINE__);
    $order['commentmanager'] = $commentmanager;
    $r = Cart::setCommentManager($order, $commentmanager);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    $ouser['order'] = $order;
    if (!$silence) {
        $r = Cart::mail($ouser, $lang, 'email');
        if (!$r) return Cart::fail($ans, $lang, 'CR018.a7');
    }
    Cart::setEmailDate($order);
    return Cart::ret($ans, $lang, 'CR055.A1');
} elseif ($action == 'wait') {
    if (!Cart::setStatus($order, 'wait')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    if (!$fuser) {
        if ($place == 'admin') $fuser = $ouser;
        else if ($place == 'orders') $fuser = $user;
    }
    if (!$fuser) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    $r = Cart::setActive($order, $fuser);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans, $lang, 'CR030.a' . __LINE__);
} elseif ($action == 'delete') {
    $r = Cart::delete($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans, $lang, 'CR027.a' . __LINE__);
} elseif ($action == 'remove') {
    $position_ids = Ans::REQ('position_ids', 'string'); //Через запятую
    if (!$position_ids) return Cart::fail($ans, $lang, 'CR033.a' . __LINE__);
    $position_ids = explode(',', $position_ids);
    foreach ($position_ids as $i => $id) {
        $position_ids[$i] = (int) $id;
        if (!$position_ids[$i]) return Cart::fail($ans, $lang, 'CR033.a' . __LINE__);
    }
    $r = Cart::removePos($position_ids);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    if (sizeof($position_ids) > 1) {
        return Cart::ret($ans, $lang, 'CR057.a' . __LINE__);
    } else {
        return Cart::ret($ans, $lang, 'CR034.a' . __LINE__);
    }
} elseif ($action == 'clear') {
    if (!Cart::clear($order)) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans, $lang, 'CR037.a' . __LINE__);
} elseif ($action == 'add') {
    $count = Ans::REQ('count', 'int', 1);
    $r = Cart::add($order, $model, $count);
    if (!$r) return Cart::fail($ans, $lang, 'CR015.a' . __LINE__);
    return Cart::ret($ans, $lang, 'CR029.a' . __LINE__);
} elseif ($action == 'addremove') {
    $count = Ans::REQ('count', 'int', false);
    if (!$count) $count = false;

    $r = Cart::add($order, $model, $count);
    if (!$r) return Cart::fail($ans, $lang, 'CR015.a' . __LINE__);
    if ($count) return Cart::ret($ans, $lang, 'CR029.a' . __LINE__);
    else return Cart::ret($ans, $lang, 'CR034.a' . __LINE__);
} elseif ($action == 'setlang') {
    //Вызывается для активного заказа при изменении языка на сайте
    //rules, $order, $lang уже есть надо его сохранить
    $r = Cart::setLang($order, $lang);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'setcoupon') {
    $coupon = Ans::REQ('coupon');
    $coupondata = Load::loadJSON('-cart/coupon?name=' . $coupon);

    $r = Cart::setCoupon($order, $coupon, $coupondata);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    //return Cart::fail($ans, $lang, 'badcoupon.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'setcity') {
    //При изменении города пересчитывается корзина. Стоимость доставки будет другой.

    $r = Cart::setCity($order, $city_id);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'settransport') {
    $transport = Ans::REQ('transport', Cart::$conf['transports']);
    if (!$transport) return Cart::fail($ans, $lang, 'CR060.a' . __LINE__);
    $r = Cart::setTransport($order, $transport);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'setpay') {
    $pay = Ans::REQ('pay', Cart::$conf['pays']);
    if (!$pay) return Cart::fail($ans, $lang, 'CR062.a' . __LINE__);
    $r = Cart::setPay($order, $pay);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'edit') {
    $email = Ans::REQ('email');
    if (!Mail::check($email)) return Cart::err($ans, $lang, 'CR005.a' . __LINE__);

    $phone = Ans::REQ('phone');
    if ((strlen($phone) < 7 || strlen($phone) > 30)) return Cart::err($ans, $lang, '5.a' . __LINE__);

    $name = Ans::REQ('name');
    if ((strlen($name) < 2 || strlen($name) > 150)) return Cart::err($ans, $lang, 'CR026.a' . __LINE__);

    $comment = Ans::REQ('comment', 'string', '');
    $address = Ans::REQ('address', 'string', '');
    $zip = Ans::REQ('zip', 'string', '');

    $city = City::getById($city_id, $lang);
	if (!$city) return Cart::fail($ans, $lang, 'CR059.a'.__LINE__);

    $ouser = User::getByEmail($email);
    if (!$ouser) {
        //Создать пользователя может и админ и просто пользователь на свободный email
        //Пользователь остаётся в своей авторизации если она есть
        
        $ouser = User::create($lang, $city['city_id'], $timezone, $email); //Создаём пользователя на указанный в заказе email и навязываем своё окружение
        if (!$ouser) return Cart::fail($ans, $lang, 'CR009.a' . __LINE__);
        //Авторизуемся если ещё нет
        if (!$user) $ans['token'] = $ouser['user_id'] . '-' . $ouser['token'];
    } else {
        if ($ouser['user_id'] == $user['user_id']) {
            $r = User::setEnv($ouser, $timezone, $lang, $city['city_id']);
            if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
        }
        if ($ouser['user_id'] != $user['user_id'] && empty($user['admin'])) {
            //Если на указанный email есть регистрация и это не я. Админ может указывать любой ящик без авторизации и приписать ему заказ
            $ouser['order'] = $order;
            $r = User::mail($ouser, $userlang, 'userdata', '/cart/orders/' . $order['order_nick']);
            if (!$r) return Cart::ret($ans, $lang, 'CR023.a' . __LINE__);
            return Cart::ret($ans, $lang, 'CR022.a' . __LINE__);
        }
    }

    $r = Cart::edit($order, [
        ':phone' => $phone,
        ':comment' => $comment,
        ':address' => $address,
        ':zip' => $zip,
        ':email' => $email,
        ':name' => $name
    ]);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

    $order = Cart::getById($order['order_id']);
    $r = Cart::setOwner($order, $ouser);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

    if ($place == 'orders') {
        $r = Cart::setActive($order, $ouser);
        if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
    }


    return Cart::ret($ans, $lang, 'CR024.a' . __LINE__);
} elseif ($action == 'order') {
    if ($user && $place == 'orders' && !$order) $order = Cart::getActiveOrder($user);
    if (!$order) return Cart::ret($ans, $lang, 'empty.a' . __LINE__);
    $ans['rule'] = Cart::getJsMetaRule($meta, $order['status'], $lang);
    $ans['order'] = $order;
    if (!sizeof($order['basket'])) return Cart::ret($ans, $lang, 'empty.a' . __LINE__);
    return Cart::ret($ans);
} elseif ($action == 'ousers') {
    if (!$order) return Cart::fail($ans, $lang, 'CR002.a' . __LINE__);
    $users = Cart::getUsers($order);
    $ans['users'] = $users;
    return Cart::ret($ans);
} elseif ($action == 'create') {
    if (!$fuser) $fuser = $user;
    if (!$fuser) return Cart::fail($ans, $lang, 'CR017.a' . __LINE__);

    $order = Cart::create($fuser);
    if (!$order) return Cart::fail($ans, $lang, 'CR008.a' . __LINE__);
    $ans['order'] = $order;
    return Cart::ret($ans);
} elseif ($action == 'cart') {
    $status = ''; //Все статусы
    $wait = true; //Нужно ли брать в расчёт ожидающие заказы
    $start = 0;
    $end = time();
    if (!$user) return Cart::err($ans, $lang, 'noorders.a' . __LINE__);
    $list = Cart::getOrders($user, $status, $wait, $start, $end);
    if (!$list) return Cart::err($ans, $lang, 'CR006.a' . __LINE__);
    foreach ($list as $k => $order) {
        $list[$k]['active'] = Cart::isActive($order, $user);
    }
    $ans['list'] = $list;
    $ans['meta'] = Cart::getJsMeta($meta, $lang);
    return Cart::ret($ans);
} elseif ($action == 'orders') {
    $status = Ans::REQ('status', 'string', '');
    $wait = Ans::REQ('wait', 'int', 0); //Нужно ли брать в расчёт ожидающие заказы
    $start = Ans::REQ('start', 'int', 0);
    $end = Ans::REQ('end', 'int', 0);
    if ($place == 'orders') {  //Заказы этого человека
        if (!$fuser) {
            $fuser = $user;
            $end = time();
        }
        $wait = true;
    } else {
        if ($fuser) {
            $wait = true;
            $start = 0;
            $end = time();
        } else {
            if (!$start) $start = strtotime('first day of month');
            if (!$end) $end = strtotime('first day of +1 month');
        }
    }
    $list = Cart::getOrders($fuser, $status, $wait, $start, $end);
    if (!$list) return Cart::err($ans, $lang, 'CR006.a' . __LINE__);
    $ans['list'] = $list;
    return Cart::ret($ans);
} else {
    return Cart::fail($ans, $lang, 'CR001.a' . __LINE__);
}
