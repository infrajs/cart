CREATE TABLE IF NOT EXISTS `cart_orders` (
    `order_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `order_nick` int(8) unsigned,
    `comment` TEXT NULL COMMENT '',
    `answer` TEXT NULL COMMENT '',
    `email` varchar(255) NULL,
    `fio` varchar(255) NULL,
    `status` varchar(255) NULL COMMENT 'Статус active может быть только у одной заявки пользователя, но может и не быть',
    `lang` ENUM('ru','en') COMMENT 'Определённый язык интерфейса посетителя',
    `coupon` TINYTEXT NULL COMMENT 'Привязанный купон',

    `sum` DECIMAL(19,2) NULL COMMENT 'Кэш расчитанной стоимости из cart_basket',
    

    -- оплата
    `payd` int(1) unsigned COMMENT 'Метка была ли онлайн оплата',

    -- доставка
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
    `datestatus` DATETIME NULL COMMENT 'Дата изменения статуса',
    `dateedit` DATETIME NULL COMMENT 'Дата редактирования',
    
    PRIMARY KEY (`order_id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;


CREATE TABLE IF NOT EXISTS `cart_basket` (
    
    `order_id` MEDIUMINT unsigned NOT NULL,
    `basket_num` SMALLINT unsigned NOT NULL COMMENT 'Порядковый номер. Пересчитывается при удалении из корзины.',
    `basket_title` TEXT NULL COMMENT 'Представление для общего списка в списке заявок, например article',

    
    `position_id` MEDIUMINT unsigned NOT NULL,
    -- зафиксированные данные
    `position_hash` VARCHAR(255) NULL COMMENT 'хэш данных позиции - было ли изменение в описании замороженной позиции используется до распаковки json и сравнения его с позицией в каталоге',
    `position_json` MEDIUMTEXT NULL COMMENT 'В json-данных должен быть hash, так как показываем мы json. freeze json позиции с собранным kits. Может быть пустой объект если позиции на момент фриза в каталоге нет.',
    --/ данные по позиции

    
    `count` SMALLINT unsigned NOT NULL COMMENT 'Количество',
    `sum` DECIMAL(19,2) NULL COMMENT 'Кэш расчитанной стоимости',
    
    `dateadd` DATETIME NULL DEFAULT NULL COMMENT 'Дата добавления',

    PRIMARY KEY (`order_id`, `basket_num`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `cart_positions` (
    `position_id` MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
    `producer_nick` VARCHAR(255) NOT NULLCOMMENT 'Игнорируется если есть json. showcase_producers. позиции в каталоге может не быть, тогда строчка не показывается, а во json записывается пустой объект',
    `article_nick` VARCHAR(255) NOT NULL COMMENT 'Игнорируется если есть json. showcase_articles',
    `item_num` VARCHAR(255) NOT NULL COMMENT 'Игнорируется если есть json. showcase_items -> showcase_models',
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

-- Нужно проверять есть ли у позиции в корзине какая-то доп.комплектация
CREATE TABLE IF NOT EXISTS `cart_kits` (
    `order_id` MEDIUMINT unsigned NOT NULL,
    `basket_num` SMALLINT unsigned NOT NULL,
    `position_id` MEDIUMINT unsigned NOT NULL,
    `kit_position_id` MEDIUMINT unsigned NOT NULL,
    `kit_count` SMALLINT unsigned NOT NULL,
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;