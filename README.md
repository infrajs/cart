# Корзина для каталога

## Установка через composer

```
{
	"require":{
		"infrajs/cart":"~1"	
	}
}
```

## Корзина
Скрипты и стили применяюстя к элементов внутри элемента с классом cart. Например, чтобы иконка корзины заработала необходимо кроме вёрстки кнопки убедиться, что у какого-то родительского элемента есть класс cart. 

Иконка корзины скрывает или показывает следующий за ней html-элемент.

Пример реализации можно посмотреь в catalog/extend.tpl

В корзину добавляется модель с временным индексом позиции. Пока товар в корзине этот индекс может измениться, тогда в корзине покажется новый товар. Но когда корзина отправится на модерацию сохранится уже сама позиция.

Сгенерированные идентификаторы не используюся, со всеми вытекающими минусами и плюсами. Позиция идентифицируется по производителю, артикулу и параметрами позиции, например размер или цвет. Технически в стрку это записывается только временно Производитель-Артикул-ВременныйИндексПозиции в дальнейшем товар характеризует и сохраняется всё описание. То есть при изменении данных в каталоге в заявке будет старое  описание по котором товар был заказан с ценой и выбранной позицией хранящейся уже без индекса.

## Иконки
С корзиной устанавливается комплект иконок [7-stroke](http://themes-pixeden.com/font-demos/7-stroke/) 
из репозитария [grimmlink/pixeden-stroke-7-icon](https://github.com/grimmlink/pixeden-stroke-7-icon)

## Параметры .infra.json

### Параметр opt
При true в каталоге начинают обрабатываться две цены ```Оптовая цена``` и ```Розничная цена```