//import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
//import { Event } from '/vendor/infrajs/event/Event.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Cart } from '/vendor/infrajs/cart/Cart.js'
//import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { DOM } from '/vendor/akiyatkin/load/DOM.js'
//import { User } from '/vendor/infrajs/user/User.js'
import { Config } from '/vendor/infrajs/config/Config.js'
//import { Global } from '/vendor/infrajs/layer-global/Global.js'


if (~Config.get('cart').transports.indexOf('cdek_pvz')) {
	(async () => {
		const { CDEK } = await import('/vendor/infrajs/cart/cdek/CDEK.js')
		CDEK.done('change', async wat => {
			const order_id = wat.order.order_id
			const city_id = wat.city
			const transport = wat.id == 'courier' ? 'cdek_courier' : 'cdek_pvz'
			const place = "orders"
			if (!wat.PVZ) return;
			const pvz = transport == 'cdek_pvz'? wat.id + ' ' + wat.PVZ.Address : ''
			Cart.post('setcdek', { order_id, place }, { city_id, transport, pvz })
		})
	})()
}

// DOM.once('load', async () => {
// 	await CDN.fire('load','jquery')
// })
DOM.once('check', async () => {
	let Template = (await import('/vendor/infrajs/template/Template.js')).Template
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	}
})

