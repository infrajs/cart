<?php

use infrajs\db\Db;



$sql = "ALTER TABLE `cart_orders` ADD `user_id` MEDIUMINT unsigned NULL COMMENT 'Автор кто непосредственно создал заказ' AFTER `lang`";
Db::exec($sql);


$sql = "ALTER TABLE `cart_orders` ADD `datefreeze` DATETIME NULL COMMENT 'Дата последней заморозки заказа, если такая была' AFTER `dateedit`";
Db::exec($sql);
