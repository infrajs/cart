Event.handler('Controller.onshow', function () {
	var activate = function (a, id) {
		var name = 'user.basket.'+id;
		var r = Session.get(name);
		var orderid = a.data('order');
		if (r || orderid) {
			a.next().stop().slideDown();
			a.addClass('selected');
			a.attr('title','Удалить из корзины');
		} else {
			a.next().stop().slideUp();	
			a.removeClass('selected');
			a.attr('title','Добавить в корзину');
		}
	}
	$('.cart .abasket').filter("[data-crumb!=false]").attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		var prodart = a.data('producer')+' '+a.data('article');
		var orderid = a.data('order');
		Cart.toggle(orderid, prodart, function () {
			activate(a, id);	
		});	
	}).each(function(){
		var a = $(this);
		var id = a.data('producer')+' '+a.data('article');
		activate(a, id)
	});
});