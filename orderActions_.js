infra.require('*cart/cart.js');
window.orderActions = {
	blockform: function(id){
		if(!id) id = "#informationForm";
		$(id+" input").attr("disabled","disabled");
		$(id+" button").attr("disabled","disabled");
		$(id+" textarea").attr("disabled","disabled");
		$(id+" select").attr("disabled","disabled");
	},
	unblockform: function(id){
		if(!id) id = "#informationForm";
		$(id+" input").removeAttr("disabled");
		$(id+" button").removeAttr("disabled");
		$(id+" textarea").removeAttr("disabled");
		$(id+" select").removeAttr("disabled");
	},
	init: function(){
		$(".save").click(function(){
			var id=$(this).attr('data-id');
			var orderPage=$(this).attr('data-orderPage');
			popup.confirm('Заявка номер '+id+' будет сохранена, продолжить?',function(){ orderActions.save(id,orderPage); });
			return false;
		});
		$(".active").click(function(){
			var id=$(this).attr('data-id');
			var orderPage=$(this).attr('data-orderPage');
			popup.confirm('Заявка номер '+id+' будет сделана активной.',function(){ orderActions.active(id,orderPage); });
			return false;
		});
		$(".act-cart").click(function(){
			infra.State.go('?office/cart');
		});
		$(".check").click(function(){
			var id=$(this).attr('data-id');
			var orderPage=$(this).attr('data-orderPage');
			popup.confirm('Заявка будет отправлена на проверку.<br> Вы не сможете производить с ней никаких действий, до окончания проверки.',function(){ orderActions.check(id,orderPage); });
			return false;
		});
		$(".copy").click(function(){
			var id=$(this).attr('data-id');
			var orderPage=$(this).attr('data-orderPage');
			popup.confirm('Вы действительно хотите скопировать заявку номер '+id+'?',function(){ orderActions.copy(id,orderPage); });
			return false;
		});
		$(".paycard").click(function(){
			var id=$(this).attr('data-id');
			orderActions.paycard(id);
			return false;
		});
		$(".refunds").click(function(){
			var id=$(this).attr('data-id');
			orderActions.refunds(id);
			return false;
		});
		$(".toPay").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявка будет отправлена на оплату.',function(){ orderActions.toPay(id); });
			return false;
		});
		$(".cancel").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявка будет отклонена. Внимание: действие необратимо.',function(){ orderActions.cancel(id); });
			return false;
		});
		$(".returnMoney").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Будет разрешён возврат денег. Внимание: действие необратимо.',function(){ orderActions.returnMoney(id); });
			return false;
		});
		$(".complete").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявке будет присвоен статус "Исполнена".',function(){ orderActions.complete(id); });
			return false;
		});
		$(".setExecution").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявке будет присвое статус "В исполнении".',function(){ orderActions.setExecution(id); });
			return false;
		});
		$(".setPicked").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявке будет присвоен статус "Укомплектована".',function(){ orderActions.setPicked(id); });
			return false;
		});
		$(".setCheck").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Заявке будет присвоен статус "На проверке", и вы сможете её редактировать.',function(){ orderActions.setCheck(id); });
			return false;
		});
		$(".remove").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Вы точно хотите удалить заявку номер '+id+'?',function(){ orderActions.realdel(id); });
			return false;
		});
		$(".clear").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Вы точно хотите очистить заявку?',function(){ orderActions.clear(id); });
			return false;
		});
		$(".clearMyDelta").click(function(){
			var id=$(this).attr('data-id');
			popup.confirm('Вы точно хотите очистить не сохранённые изменения в заявке?',function(){ orderActions.clearMyDelta(id); });
			return false;
		});
		$(".wholesaleDelete").click(function(){
			var email=$(this).attr('data-email');
			popup.confirm(infra.template.parse('*cart/site.popups.tpl',{email:email},'wholesaleDelete'),function(){ orderActions.wholesaleDelete(email); });
			return false;
		});
	},
	save: function(id, orderPage){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=save');
		this.getJSON(path, function(result){
			if(orderPage&&result.id) infra.State.go('?office/orders/'+result.id+'/');
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['order','cat_basket','sign']);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform();
		});
	},
	active: function(id, orderPage){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=active');
		this.getJSON(path, function(result){
			if(orderPage&&result.id) infra.State.go('?office/orders/'+result.id+'/');
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['cat_basket','order']);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform();
		});
	},
	realdel: function(id){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=realdel');
		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['cat_basket','order']);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform();
		});
	},
	clear: function(id){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=clear');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['order','cat_basket']);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform();
		});
	},
	
	check: function(id, orderPage){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=check');
		this.getJSON(path, function(result){
			if(orderPage&&result.id) infra.State.go('?office/orders/'+result.id+'/');
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['sign','order','cat_basket']);
			infra.session.sync();
			infrajs.check();
		});
	},
	copy: function(id, orderPage){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=copy');

		this.getJSON(path, function(result){
			if(orderPage&&result.id) infra.State.go('?office/orders/'+result.id+'/');
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['order','cat_basket']);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform();
		});
	},
	toPay: function(id){
		orderActions.blockform('#adminForm');
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=toPay');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	cancel: function(id){
		orderActions.blockform('#adminForm');
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=cancel');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	returnMoney: function(id){
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=returnMoney');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	complete: function(id){
		orderActions.blockform('#adminForm');
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=complete');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	setExecution: function(id){
		orderActions.blockform('#adminForm');
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=setExecution');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	setPicked: function(id){
		orderActions.blockform('#adminForm');
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=setPicked');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	setCheck: function(id){
		orderActions.blockform();
		infra.loader.show('#adminForm');
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=setCheck');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform('#adminForm');
		});
	},
	paycard: function(id){
		orderActions.blockform();
		infra.loader.show('#adminForm');
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=paycard');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	refunds: function(id){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?id='+id+'&action=refunds');

		this.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set('order');
			infra.session.sync();
			infrajs.check();
		});
	},
	getJSON:function(src,call){
		$.ajax({
		  dataType: "json",
		  url: src,
		  success: call,
		  error:function(){
		  	popup.alert('Ошибка на сервере. Попробуйте позже.');
		  }
		});
	},
	clearMyDelta: function(id){
		orderActions.blockform();
		infra.loader.show();
		
		infra.session.set('manager'+id);
		popup.alert('Изменения сброшены.');
		infrajs.global.set(['order']);
		infra.session.sync();
		infrajs.check();
		orderActions.unblockform();
	},
	wholesaleDelete: function(email){
		orderActions.blockform();
		infra.loader.show();
		var path=infra.theme('*cart/orderActions.php?email='+email+'&action=wholesaleDelete');

		$.getJSON(path, function(result){
			if(result.msg)popup.alert(result.msg);
			infrajs.global.set(['order',"cat_basket"]);
			infra.session.sync();
			infrajs.check();
			orderActions.unblockform('#adminForm');
		});
	}
};