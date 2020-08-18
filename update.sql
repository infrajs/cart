CREATE TABLE IF NOT EXISTS `cart_orders` (
    `order_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `order_nick` int(8) unsigned,
    `comment` TEXT NULL COMMENT '',
    `commentmanager` TEXT NULL COMMENT '',
    `answer` TEXT NULL COMMENT '',
    `email` varchar(255) NULL,
    `phone` varchar(255) NULL,
    `name` varchar(255) NULL,
    `status` ENUM('wait','pay','check','complete') NOT NULL DEFAULT 'wait' COMMENT 'Доступные статусы',
    `lang` ENUM('ru','en') NOT NULL COMMENT 'Определёный язык интерфейса посетителя',
    `coupon` TINYTEXT NOT NULL DEFAULT '' COMMENT 'Привязанный купон',
    `freeze` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Метка заморожены ли позиции',
    `sum` DECIMAL(19,2) NOT NULL COMMENT 'Сумма к оплате с учётом купона и доставки. Пересчитывается при изменении корзины',
    `paid` int(1) unsigned NOT NULL COMMENT 'Метка была ли онлайн оплата',
    `pay` ENUM('sbrfpay','paykeeper') NULL,

    
    `city` varchar(255) NULL COMMENT 'Город определённый или изменённый, для сортировки заявок',
    `transport` ENUM(
        'city','self',
        'cdek_punkt','cdek_courier',
        'pochta_simple','pochta_1','pochta_courier'
    ) NULL,
    `cdek_punkt` TEXT NULL COMMENT 'номер пункта',
    `cdek_info` TEXT NULL COMMENT 'json о сделанном выборе',
    `address` TEXT NULL COMMENT 'Адрес в городе',
    `zip` TEXT NULL COMMENT '',
    

    `json` MEDIUMTEXT NULL COMMENT 'json с данными об оплате, доставке и прочим',
    

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


CREATE TABLE IF NOT EXISTS `cart_basket` (
    `position_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `order_id` MEDIUMINT unsigned NOT NULL,
    `basket_title` TEXT NULL COMMENT 'Представление для общего списка в списке заявок, например article',
    
    `model_id` MEDIUMINT unsigned NULL COMMENT 'Может быть NULL -- UNIQUE INDEX будет работать, если позиция удалена из каталога - тогда null и есть json или вся запись удаляется об этой позиции из корзины.',
    `item_num` SMALLINT unsigned NULL COMMENT '',
    `catkit` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Оригинальная строка идентифицирующая sum и комплектацию. NULL не может быть для работы unique index. Если нет указывается пустая строка.',
    `hash` VARCHAR(255) NULL COMMENT 'хэш данных позиции - было ли изменение в описании замороженной позиции используется до распаковки json и сравнения его с позицией в каталоге',
    `json` MEDIUMTEXT NULL COMMENT 'freeze json позиции с собранным kits. Не может быть пустой объект - если позиции на момент фриза в каталоге нет, то и в корзине позиция не покажется, так как будет удалена по событию из showcase',
    
    `cost` DECIMAL(19,2) NULL COMMENT 'Цена',
    `count` SMALLINT unsigned NOT NULL COMMENT 'Количество',
    
    `dateadd` DATETIME NULL DEFAULT NULL COMMENT 'Дата добавления',
    `dateedit` DATETIME NULL DEFAULT NULL COMMENT 'Дата изменений',
    UNIQUE INDEX (`order_id`,`model_id`, `item_num`,`catkit`),
    PRIMARY KEY (`position_id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;


CREATE TABLE IF NOT EXISTS `cart_userorders` (
    `order_id` MEDIUMINT unsigned NOT NULL,
    `user_id` MEDIUMINT unsigned NOT NULL,
    `active` tinyint(1) unsigned NULL
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;