//import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
//import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Fire } from '/vendor/akiyatkin/load/Fire.js'
import { Goal } from '/vendor/akiyatkin/goal/Goal.js'
import { User } from '/vendor/infrajs/user/User.js'
import { View } from '/vendor/infrajs/view/View.js'

import { Load } from '/vendor/akiyatkin/load/Load.js'
import { Lang } from '/vendor/infrajs/lang/Lang.js'
import { Global } from '/vendor/infrajs/layer-global/Global.js'
//import { Session } from '/vendor/infrajs/session/Session.js'
//let Template, Global, Autosave

let Cart = {
	...Fire,
	// api: async (type, param) => {
	// 	let ans = await Cart.apis(type, param)
	// 	Global.check('cart')
	// 	return ans
	// },

	// load: (type, param) => {
	// 	let src = Cart.src(type, param)
	// 	Global.unload('cart', src)
	// 	return Load.fire('json', src)
	// },
	// apis: async (type, param) => {
	// 	let src = Cart.src(type, param)
	// 	let ans = await Load.puff('json', src)
	// 	return ans
	// },

	
	dis (form, val = true) {
		if (val && form.dataset.proc == 'true') return true
		form.dataset.proc = val
		for (let el of form.elements) {
			el.disabled = val
		}
	},
	get: (type, param) => {
		let token = User.token()
		let lang = Cart.lang()
		param = { ...param, lang, token }
		let args = Cart.args(param)
		let src = '-cart/api/' + type + '?' + args
		Global.unload('cart', src)
		return Load.fire('json', src)
	},
	strip_tags: (html) => {
		var tmp = document.createElement("DIV")
		tmp.innerHTML = html
		return tmp.textContent || tmp.innerText || ""
	},

	post: async (type, param, opt, descr = {}) => {
		const ans = await Cart.posts(type, param, opt, descr)
		await DOM.puff('check')
		return ans
	},
	posts: async (type, param, opt, descr = {}) => {
		let token = User.token()
		let lang = Cart.lang()
		const { City } = await import('/vendor/akiyatkin/city/City.js')
		let city_id = City.id()
		let timezone = Intl.DateTimeFormat ? Intl.DateTimeFormat().resolvedOptions().timeZone : ''
		let submit = 1

		const groupsrc = '-cart/api/' + type + '?' + Cart.args({ city_id, ...param, lang, submit, token, timezone })

		let ans
		if (opt) {
			const src = groupsrc + '&' + Cart.args(opt)
			ans = await Load.puff('json', src, groupsrc)
		} else {
			const src = groupsrc
			ans = await Load.emit('json', src)
		}
		
		if (~['add','addtoactive','addtoactiveifnot','clear','check','delete','remove','setcoupon'].indexOf(type)) {
			Global.set('cart-sum')
		}
		if (~['clear','addtoactive','addtoorder','addtoactiveifnot','check','delete','remove','setcoupon'].indexOf(type)) {
			Global.set("cart-list")
		}
		
		if (~['add','email','addtoactive','addtoactiveifnot',
			'setcity',
			'setcdek','setpvz','setzip', 'pay', 'check','wait','cancel','complete','delete','tocheck'].indexOf(type)) {
			Global.set('cart-order')
		}
		Global.set('cart')
		if (!ans) ans = {
			"action":{ },
			"result":0,
			"msg":"Ошибка на сервере"
		}
		if (ans.token || ans.token === '') {
			View.setCOOKIE('token', ans.token)
			View.setCOOKIE('infra_session_id')
			View.setCOOKIE('infra_session_pass')
			Global.set('user')
		}
		if (window.dataLayer && ~['pay', 'check'].indexOf(type)) {
			const products = descr.basket.map( ({ model }) => {
				return {
					"id": model.article,
					"price": model.Цена,
					"brand": model.producer,
					"category": model.group,
					"variant": model.item_num + (model.catkit?'&':'') + model.catkit,
					"quantity": 1
				}
			})
			const ecom = {
				"ecommerce": {
					"currencyCode": "RUB",
					"purchase": {
						"actionField": {
							"id" : descr.order_nick
						},
						"products": products
					}
				}
			}
			console.log(ecom.ecommerce)
			dataLayer.push(ecom)
		}
		if (window.dataLayer && ~['addtoactive'].indexOf(type)) {
			const pos = {...opt, ...param}
			//{ place, producer_nick, article_nick, catkit, item_num }, { count }
			const dif = descr.dif
			if (dif > 0) {
				const ecom = {
					"ecommerce": {
						"currencyCode": "RUB",    
						"add": {
							"products": [
								{
									"id": descr.article,
									"price": descr.cost,
									"brand": descr.producer,
									"category": descr.group,
									"variant": pos.item_num + (pos.catkit?'&':'') + pos.catkit,
									"quantity": dif
								}
							]
						}
					}
				}
				console.log(ecom.ecommerce)
				window.dataLayer.push(ecom)
			} else if (dif < 0) {
				const ecom = {
					"ecommerce": {
						"currencyCode": "RUB",    
						"remove": {
							"products": [
								{
									"id": descr.article,
									"price": descr.cost,
									"brand": descr.producer,
									"category": descr.group,
									"variant": pos.item_num + (pos.catkit?'&':'') + pos.catkit,
									"quantity": -dif
								}
							]
						}
					}
				}
				console.log(ecom.ecommerce)
				window.dataLayer.push(ecom)
			}
		}
		return ans
	},
	maplayer: {
		"tpl":"-cart/layout.tpl",
		"tplroot":"MAP"				
	},
	args: (param) => {
		let args = [];
		let keys = Object.keys(param).sort()
		for (let key of keys) args.push(key + '=' + encodeURIComponent(param[key]))
		args = args.join('&')
		return args
	},
	lang: str => {
		if (typeof (str) == 'undefined') return Lang.name('user');
		return Lang.str('cart', str);
	}
}

window.Cart = Cart
export { Cart }