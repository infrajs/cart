<?php

use infrajs\db\Db;

$sql = "ALTER TABLE `cart_orders` ADD `datecancel` DATETIME NULL COMMENT 'Дата отмены' AFTER `dateedit`";
Db::exec($sql);

$sql = "ALTER TABLE `cart_orders` CHANGE `status` `status` ENUM('wait','pay','check','complete','cancel') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'wait' COMMENT 'Доступные статусы';";
Db::exec($sql);


$sql = "ALTER TABLE `cart_orders` ADD `user_id` MEDIUMINT unsigned NULL COMMENT 'Автор кто непосредственно создал заказ' AFTER `lang`";
Db::exec($sql);


$sql = "ALTER TABLE `cart_orders` ADD `datefreeze` DATETIME NULL COMMENT 'Дата последней заморозки заказа, если такая была' AFTER `dateedit`";
Db::exec($sql);
