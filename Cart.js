import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
//import { Ascroll } from '/vendor/infrajs/ascroll/Ascroll.js'
//import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Fire } from '/vendor/akiyatkin/load/Fire.js'
import { Goal } from '/vendor/akiyatkin/goal/Goal.js'
import { User } from '/vendor/infrajs/user/User.js'
import { City } from '/vendor/akiyatkin/city/City.js'
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

	post: async (type, param, opt) => {
		const ans = await Cart.posts(type, param, opt)
		await DOM.puff('check')
		return ans
	},
	posts: async (type, param, opt) => {
		let token = User.token()
		let lang = Cart.lang()
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
		if (ans.actionmeta && ans.actionmeta.goal && ans.result) Goal.reach(ans.actionmeta.goal)
		
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