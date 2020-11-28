import { Fire } from '/vendor/akiyatkin/load/Fire.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Load } from '/vendor/infrajs/load/Load.js'
import { Cart } from '/vendor/infrajs/cart/Cart.js'

export let CDEK = {
	...Fire,
	// calc: async (order, type = "courier") => {
	// 	//type: courier, pickup
	// 	let get = {
	// 		isdek_action: "calc",
	// 		timestamp:Date.now(),
	// 		shipment: {
	// 			cityFromId: Config.get('cdek').cityFromId, //Москва
	// 			cityToId: Session.get('orders.my.cdek.wat.city', Config.get('cdek').defaultCityId),
	// 			"type":type,
	// 			"goods":await CDEK.getGoods(order)
	// 		}
	// 	}
	// 	let json = await fetch('/-cart/cdek/service.php?' + Load.param(get)).then(async res => await res.json())
	// 	/*
	// 		price: "780"
	// 		deliveryPeriodMin: 2
	// 		deliveryPeriodMax: 3
	// 	*/

	// 	return json
	// },
	change: async (wat, order) => {
		if (!wat) return
		wat.order = order
		if (wat.PVZ) {
			delete wat.PVZ.Picture
			delete wat.PVZ.placeMark
			delete wat.PVZ.list_block
		}
		CDEK.puff('change', wat)
	},
	open: async (order) => {
		import('/vendor/akiyatkin/hatloader/HatLoader.js').then( (obj) => {
			let HatLoader = obj.default;
			HatLoader.show('Загружается карта...')
		})
		const cartWidjet = await CDEK.getCartWidjet(order)
		
		
		cartWidjet.open()
		const checkCity = cartWidjet.city.check(order.city.city)
        if (checkCity) cartWidjet.city.set(order.city.city)
		import('/vendor/akiyatkin/hatloader/HatLoader.js').then( (obj) => {
			let HatLoader = obj.default;
			HatLoader.hide()
		})
	},
	close: async () => {
		let cartWidjet = await CDEK.getCartWidjet()
		cartWidjet.close()
	},
	getCartWidjet: async (order) => {
		if (!window.cartWidjet) {
			await CDN.fire('load','cdek.widget')
			let option = {
				//defaultCity: 'Тольятти', //какой город отображается по умолчанию
				defaultCity: order.city.city,
				country: order.city.country,
				//city: order.city_id,
				cityFrom: Config.get('cart').city_from, // из какого города будет идти доставка
				//country: 'Россия',
				hidedress: true,
				hidecash: true,
				hidedelt: true,
				servicepath: '/-cart/cdek/service.php',
				popup: true,
				path: 'https://widget.cdek.ru/widget/scripts/',
				//path2: '/-catalog/cdek/widget/scripts/',
				//path: '/vendor/akiyatkin/cdek/lib/widget/scripts/',
				apikey: Config.get('cart').yandexapikey,
				choose:true,
				onReady: async () => {
					await CDN.fire('load','jquery')
					$('.CDEK-widget__popup__close-btn').attr('data-crumb','false').attr('onclick','return false');
				},
				onChooseProfile: wat => CDEK.change(wat, order),
				onCalculate: wat => CDEK.change(wat, order),
				onChoose: wat => CDEK.change(wat, order),
				goods: await CDEK.getGoods(order)
			}
			window.cartWidjet = new ISDEKWidjet(option);
		}
		if (cartWidjet.loadedToAction) {
			return cartWidjet
		} else {
			return new Promise(resolve => {
				let timer = setInterval(() => {
					if (!cartWidjet.loadedToAction) return
					clearInterval(timer)
					resolve(cartWidjet)
				}, 300)	
			})
		}
	},
	getDim: item => {
		//$item['Габариты']//WxHxL

		let dim = item['Упаковка, см'] ? item['Упаковка, см']: '';
		let weight = item['Вес, кг'] ? item['Вес, кг']: '0.4';

		let d = dim.split(/[хx]/i)
		
		if (!d[0]) d[0] = 6;
		if (!d[1]) d[1] = 15;
		if (!d[2]) d[2] = 12;
		weight = Number(weight);

		return { 
			"width": d[0], 
			"height": d[1], 
			"length": d[2], 
			"weight": weight
		}
	},
	getGoods: async (order) => {
		let goods = []
		for (let i in order.basket) {
			let pos = order.basket[i]
			let dim = CDEK.getDim(pos.model)
			for (let i = 0; i < pos['count']; i++) {
				goods.push(dim)
			}
		}
		return goods
	}
}
window.CDEK = CDEK
export default CDEK