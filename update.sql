CREATE TABLE IF NOT EXISTS `cart_orders` (
    `order_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `order_nick` int(10) unsigned,
    `comment` TEXT NULL COMMENT '',
    `commentmanager` TEXT NULL COMMENT '',
    `email` TINYTEXT NULL,
    `phone` TINYTEXT NULL,
    `name` TINYTEXT NULL,
    `callback` ENUM('yes','no','') NOT NULL DEFAULT '',
    `status` ENUM('wait','pay','check','complete') NOT NULL DEFAULT 'wait' COMMENT 'Доступные статусы',
    `lang` ENUM('ru','en') NOT NULL COMMENT 'Определёный язык интерфейса посетителя',
    
    `freeze` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Метка заморожены ли позиции',
    `paid` int(1) unsigned NOT NULL COMMENT 'Метка была ли онлайн оплата',
    `pay` ENUM('self','card','corp') NULL,
    `paydata` JSON NULL DEFAULT NULL COMMENT 'Данные оплаты',
    
    `city_id` MEDIUMINT NULL COMMENT 'Город определённый или изменённый, для сортировки заявок и расчёта стоимости доставки. Может отличаться от выбранного города в заказе',
    `coupon` TINYTEXT NOT NULL DEFAULT '' COMMENT 'Привязанный купон',
    `coupondata` JSON NULL DEFAULT NULL COMMENT 'Данные купона',
    `transport` ENUM(
        'city','self','cdek_pvz',
        'cdek_courier','pochta_simple','pochta_1',
        'pochta_courier'
    ) NULL COMMENT 'Выбор пользователя',
    `pvz` TEXT NULL COMMENT 'Адрес в городе',
    `address` TEXT NULL COMMENT 'Адрес в городе',
    `zip` TEXT NULL COMMENT 'Индекс',
    `count` SMALLINT unsigned NOT NULL COMMENT 'Кэш количества позиций в корзине',

    `datecreate` DATETIME NULL COMMENT 'Дата создания',
    `datewait` DATETIME NULL COMMENT 'Дата изменения статуса',
    `datepay` DATETIME NULL COMMENT 'Дата изменения статуса',
    `datepaid` DATETIME NULL COMMENT 'Дата подтверждения оплаты',
    `datecheck` DATETIME NULL COMMENT 'Дата изменения статуса',
    `datecomplete` DATETIME NULL COMMENT 'Дата изменения статуса',
    `dateemail` DATETIME NULL COMMENT 'Дата email пользователю',
    `dateedit` DATETIME NULL COMMENT 'Дата редактирования',
    
    PRIMARY KEY (`order_id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;


CREATE TABLE IF NOT EXISTS `cart_transports` (
    `order_id` MEDIUMINT unsigned NOT NULL,
    `type` ENUM(
        'city','self','cdek_pvz',
        'cdek_courier','pochta_simple','pochta_1',
        'pochta_courier'
    ) NULL COMMENT 'Выбор пользователя',
    `cost` SMALLINT NULL COMMENT 'Цена',
    `min` TINYINT NULL COMMENT 'Cрок в днях',
    `max` TINYINT NULL COMMENT 'Cрок в днях',
    UNIQUE INDEX (`order_id`,`type`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `cart_basket` (
    `position_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `order_id` MEDIUMINT unsigned NOT NULL,
    `costclear` DECIMAL(10,2) NULL COMMENT 'Кэш цены',
    
    `article_nick` TINYTEXT NOT NULL COMMENT '',
    `producer_nick` TINYTEXT NOT NULL COMMENT '',
    `item_num` SMALLINT unsigned NULL COMMENT '',
    `catkit` TINYTEXT NOT NULL DEFAULT '' COMMENT 'Оригинальная строка идентифицирующая sum и комплектацию. NULL не может быть для работы unique index. Если нет указывается пустая строка.',

    `hash` TINYTEXT NULL COMMENT 'хэш данных позиции - было ли изменение в описании замороженной позиции используется до распаковки json и сравнения его с позицией в каталоге',
    `json` MEDIUMTEXT NULL COMMENT 'freeze json позиции с собранным kits. Не может быть пустой объект - если позиции на момент фриза в каталоге нет, то и в корзине позиция не покажется, так как будет удалена по событию из showcase',
    
    `discount` INT(2) NULL COMMENT 'Скидка по купону',
    `count` SMALLINT unsigned NOT NULL COMMENT '',
    
    `dateadd` DATETIME NULL DEFAULT NULL COMMENT 'Дата добавления',
    `dateedit` DATETIME NULL DEFAULT NULL COMMENT 'Дата изменений',

    PRIMARY KEY (`position_id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;


CREATE TABLE IF NOT EXISTS `cart_userorders` (
    `order_id` MEDIUMINT unsigned NOT NULL,
    `user_id` MEDIUMINT unsigned NOT NULL,
    `active` tinyint(1) unsigned NULL
    PRIMARY KEY (`order_id`, `user_id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;