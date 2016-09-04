Event.handler('Controller.onshow', function () {
	var activate = function (a, id) {
		var name = 'user.basket.'+id;
		var r = Session.get(name);
		if (r) {
			a.next().slideDown();
			a.addClass('selected');
			a.attr('title','Удалить из корзины');
		} else {
			a.next().slideUp();	
			a.removeClass('selected');
			a.attr('title','Добавить в корзину');
		}
	}
	$('.cart .abasket').attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		var id = a.data('producer')+' '+a.data('article');
		Cart.toggle(id, function () {
			activate(a, id);	
		});	
	}).each(function(){
		var a = $(this);
		var id = a.data('producer')+' '+a.data('article');
		activate(a, id)
	});
});