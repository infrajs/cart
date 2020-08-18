<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\mail\Mail;
use akiyatkin\showcase\Showcase;
use infrajs\path\Path;

// Обработка actions
if ($action == 'check') {
    if (!Cart::setStatus($order, 'check')) return Cart::fail($ans, $lang, 'CR018.1A');
    $ouser['order'] = $ouser;
    if (!$silence) {
        if ($place == 'orders') {
            Cart::mailtoadmin($ouser, $lang, 'AdmOrderToCheck');
        }
        Cart::mail($ouser, $lang, 'orderToCheck');
    }
    //После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
    $r = Cart::resetActive($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.2A');
    return Cart::ret($ans, $lang, 'CR025.1A');
} elseif ($action == 'years') {
    $years = Cart::getYears();
    $ans['years'] = $years;
    return Cart::ret($ans);
} elseif ($action == 'meta') {
    $jsmeta = [];

    $jsmeta['actions'] = [];
    foreach ($meta['actions'] as $a => $orig) {
        if (empty($orig['title'])) continue;
        $new = [];
        $new['title'] = Cart::ln($orig['title'], $lang);
        $jsmeta['actions'][$a] = $new;
    }

    $jsmeta['rules'] = [];
    foreach ($meta['rules'] as $a => $orig) {
        if (empty($orig['title'])) continue;
        $new = [];
        $new['title'] = Cart::ln($orig['title'], $lang);
        if (!empty($orig['user'])) $new['user'] = $orig['user'];
        if (!empty($orig['manager'])) $new['manager'] = $orig['manager'];
        $jsmeta['rules'][$a] = $new;
    }
    $ans['meta'] = $jsmeta;
    return Cart::ret($ans);
} elseif ($action == 'complete') {
    if (!Cart::setStatus($order, 'complete')) return Cart::fail($ans, $lang, 'CR018.14A');
    //После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
    $r = Cart::resetActive($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.15A');
    return Cart::ret($ans, $lang, 'CR040.1A');
} elseif ($action == 'email') {
    $ouser['order'] = $order;
    if (!$silence) {
        $r = Cart::mail($ouser, $lang, 'email');
        if (!$r) return Cart::fail($ans, $lang, 'CR018.16A');
    }
    Cart::setEmailDate($order);
    return Cart::ret($ans, $lang, 'CR055.M1');
} elseif ($action == 'wait') {
    if (!Cart::setStatus($order, 'wait')) return Cart::fail($ans, $lang, 'CR018.8A');
    if (!$fuser) {
        if ($place == 'admin') $fuser = $ouser;
        else if ($place == 'orders') $fuser = $user;
    }
    if (!$fuser) return Cart::fail($ans, $lang, 'CR018.11A');
    $r = Cart::setActive($order, $fuser);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.9A');
    return Cart::ret($ans, $lang, 'CR030.1A');
} elseif ($action == 'delete') {
    $r = Cart::delete($order);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.3A');
    return Cart::ret($ans, $lang, 'CR027.1A');
} elseif ($action == 'remove') {
    $position_ids = Ans::REQ('position_ids', 'string'); //Через запятую
    if (!$position_ids) return Cart::fail($ans, $lang, 'CR033.1A');
    $position_ids = explode(',', $position_ids);
    foreach ($position_ids as $i => $id) {
        $position_ids[$i] = (int) $id;
        if (!$position_ids[$i]) return Cart::fail($ans, $lang, 'CR033.2A');
    }
    $r = Cart::removePos($position_ids);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.12A');
    if (sizeof($position_ids) > 1) {
        return Cart::ret($ans, $lang, 'CR057.1A');
    } else {
        return Cart::ret($ans, $lang, 'CR034.1A');
    }
} elseif ($action == 'clear') {
    if (!Cart::clear($order)) return Cart::fail($ans, $lang, 'CR018.13A');
    return Cart::ret($ans, $lang, 'CR037.1A');
} elseif ($action == 'add') {
    $count = Ans::REQ('count', 'int', 1);
    $r = Cart::add($order, $model, $count);
    if (!$r) return Cart::fail($ans, $lang, 'CR015.1');
    return Cart::ret($ans, $lang, 'CR029.1A');
} elseif ($action == 'sync') {
    //$rule, $order, $place
    //Сделать freeze и получение позиций корзины
    if (empty($rule['edit'][$place])) return Cart::err($ans, $lang, 'CR028.1A');

    $email = Ans::REQ('email');
    if ($email && !Mail::check($email)) return Cart::err($ans, $lang, 'CR005.3A');

    $phone = Ans::REQ('phone');
    if ($phone && (strlen($phone) < 7 || strlen($phone) > 15)) return Cart::err($ans, $lang, 'CR021.1A');

    $name = Ans::REQ('name');
    if ($name && (strlen($name) < 2 || strlen($name) > 150)) return Cart::err($ans, $lang, 'CR026.1A');

    //Если меняется email надо ли удалять старого владельца?

    $fuser = User::getByEmail($email);
    if (!$fuser) { //Создаём пользователя
        $fuser = User::create($email);
        if (!$fuser) return Cart::fail($ans, $lang, 'CR009.2');
        $ans['token'] = $fuser['user_id'] . '-' . $fuser['token'];
    } else if ($fuser['user_id'] != $user['user_id'] && empty($user['admin'])) {
        //Если на указанный email есть регистрация и это не я. Админ может указывать любой ящик без авторизации и приписать кому-то заявку
        $fuser['order'] = $order;
        $r = User::mail($fuser, $userlang, 'userdata', '/cart/orders/' . $order['order_nick']);
        if (!$r) return Cart::ret($ans, $lang, 'CR023.1A');
        return Cart::ret($ans, $lang, 'CR022.1A');
    }

    $r = Cart::sync($order, [
        ':phone' => $phone,
        ':email' => $email,
        ':name' => $name,
        ':lang' => $lang
    ]);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.4A');
    $order = Cart::getById($order['order_id']);
    $r = Cart::setOwner($order, $fuser);
    if (!$r) return Cart::fail($ans, $lang, 'CR018.5A');
    return Cart::ret($ans, $lang, 'CR024.1');
} elseif ($action == 'order') {
    if (!$order) return Cart::fail($ans, $lang, 'CR002.2A');
    $ans['order'] = $order;
    return Cart::ret($ans);
} elseif ($action == 'ousers') {
    if (!$order) return Cart::fail($ans, $lang, 'CR002.3');
    $users = Cart::getUsers($order);
    $ans['users'] = $users;
    return Cart::ret($ans);
} elseif ($action == 'create') {
    if (!$fuser) $fuser = $user;
    if (!$fuser) return Cart::fail($ans, $lang, 'CR017.3');

    $order = Cart::create($fuser);
    if (!$order) return Cart::fail($ans, $lang, 'CR008.B1');
    $ans['order'] = $order;
    return Cart::ret($ans);
} elseif ($action == 'orders') {
    $status = Ans::REQ('status', 'string', '');
    $wait = Ans::REQ('wait', 'int', 0); //Нужно ли брать в расчёт ожидающие заказы
    $start = Ans::REQ('start', 'int', 0);
    $end = Ans::REQ('end', 'int', 0);
    if ($place == 'orders') {  //Заказы этого человека
        if (!$fuser) $fuser = $user;
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
    if (!$list) return Cart::err($ans, $lang, 'CR006.2');
    $ans['list'] = $list;
    return Cart::ret($ans);
} else {
    return Cart::fail($ans, $lang, 'CR001.2');
}
