<?php

namespace infrajs\cart\api;

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\path\Path;
use infrajs\db\Db;
use infrajs\mail\Mail;
use akiyatkin\city\City;
use akiyatkin\showcase\Showcase;
use infrajs\lang\Lang;

class Meta {
	public function __construct($opt) {
		$this->src = $opt['src'];
		$this->name = $opt['name'];
		$this->lang = $opt['lang'];
		$this->actions = $opt['actions'] ?? [];
		$this->handlers = $opt['handlers'] ?? []; //Обработки привязанные к action
		$this->args = $opt['args'] ?? []; //Обработки привязанные к параметрам
		$this->vars = $opt['vars'] ?? [];
		$this->params = ['ans'=>[]];
	}
	public function set($pname, $val, $line = __LINE__) {
		if (isset($this->params[$pname])) return $this->fail('repeat', $line, $pname);
		$this->params[$pname] = $val;
	}
	public function init() {
		try {
			return $this->initnow();
		} catch (\Exception $e) {			
			return $this->params['ans'];
		}

	}
	public function initnow() {
	
		$ans = &$this->params['ans'];
		if (!$src = Path::theme($this->src)) return $this->fail('CR018', 'm'.__LINE__);
		if (!$json = file_get_contents($src)) return $this->fail('CR018', 'm'.__LINE__);
		$meta = json_decode($json, true);
		$this->meta = $meta;
		if (!$meta) return $this->fail('CR018', 'm'.__LINE__);		
		$action = Rest::first();
		if (!$action) {
		    $ans['meta'] = $meta;
		    return Ans::ret($ans);
		}
		
		$this->params['meta'] = $meta;

		if (!isset($meta['actions'][$action])) return $this->fail('CR001', 'm'.__LINE__);
		
		$this->actionmeta = $meta['actions'][$action];
		$this->actionmeta['action'] = $action;
		$this->actionmeta['handlers'] = $this->actionmeta['handlers'] ?? [];



		//Избавляемся от post и get
		$dependencies = $this->meta['dependencies']['get'];
		$keys = array_merge($this->meta['handlers'] ?? [], $this->meta['flags'] ?? []);
		foreach($keys as $key) {
			if (!in_array($key, $this->actionmeta['handlers'])) continue;
			if (!isset($this->meta['dependencies'][$key])) continue;
			foreach($this->meta['dependencies'][$key] as $pname => $deps) {
				if (!isset($dependencies[$pname])) $dependencies[$pname] = $deps;
				else $dependencies[$pname] = array_merge($dependencies[$pname], $deps);
			}
		}
		
		$this->dependencies = $dependencies;
		
		
		//Рекурсивно применяем все зависимости, чтобы точно знать, по плану эта переменная требуется или нет
		//И чтобы была возможность проверить всё		
		$required = array_merge($this->dependencies['default'], $this->actionmeta['required'] ?? []);
		for ($i = 0; $i<sizeof($required); $i++) {
			$pname = $required[$i];
			if (isset($this->dependencies[$pname])) {
				array_splice($required, $i+1, 0, $this->dependencies[$pname]);
			}
		}		
		$required = array_values(array_unique($required));

		$in = $required;
		for ($i = 0; $i < sizeof($in); $i++) {
			$pname = $in[$i];
			if (!isset($this->meta['args'][$pname])) {
				array_splice($in, $i, 1);
				$i--;
			}
		}
		
		// $vars = $required;
		// for ($i = 0; $i < sizeof($vars); $i++) {
		// 	$pname = $vars[$i];
		// 	if (isset($this->meta['args'][$pname])) {
		// 		array_splice($vars, $i, 1);
		// 		$i--;
		// 	}
		// }
		//$this->actionmeta['required'] = $required;
		//$this->actionmeta['vars'] = $vars;
		
		//handlers выполняется с Транзакцией если это post
		if (in_array('post', $this->actionmeta['handlers'])) Db::start();
		$this->actionmeta['required'] = array_unique($in);
		$ans['actionmeta'] = $this->actionmeta;

		foreach ($this->actionmeta['handlers'] as $hand) {
			//Изменения данных могут делать как будто всё ок, в случае ошибки будет откат
			//Можно делать freeze какбудто заказ отправлен на проверку
			$this->handler($hand, 'm'.__LINE__); //Может быть исключение ans.result = 0
		}

		$action = $this->actionmeta['action'];
		if (!isset($this->actions[$action])) return $this->fail('CR001', __LINE__, $action);
		
		//$this->params[$action] = false;
		
		
		//Может быть исключение ans.result = 0, 
		//положительный результат только return

		$this->exec($this->actions[$action], $action, $this->params[$action]); 
		
		if (in_array('post', $this->actionmeta['handlers'])) {
			if (Db::isstart()) Db::commit(); //Пред error можно сделать commit, так как с исключением сюда не попадаем
		}

		//Для положительного ответа нужен return чтобы зафиксировалась транзакция
		return $this->ret();
	}

	
	public function fail($code, $line, $pname = false) {
		$ans = &$this->params['ans'];
		$lang = $this->params['lang'] ?? $this->lang;
		$ans['params'] = array_keys($this->params);
		if (!$pname) {			
			$ans = Lang::fail($ans, $lang, $this->name.'.'.$code.'.'.$line);
			throw new \Exception();
		}
		$ans['missing'] = $pname;
		$ans = Lang::failtpl($ans, $lang, $this->name.'.'.$code.'.'.$line);
		throw new \Exception();
	}
	// public function args($pnames, $line = __LINE__) {
	// 	$res = [];
	// 	foreach ($pnames as $pname) {
	// 		$res[$pname] = &$this->arg($pname, $line);
	// 	}
	// 	return $res;
	// }
	
	public function &arg($pname, $line = __LINE__) {
		//Если параметра нет в списке нужных и это параметр из адресной строки - сообщаем об ошибки
		if (!in_array($pname, $this->actionmeta['required'])) {
			if (isset($this->args[$pname])) return $this->var($pname, $line);
			return $this->fail('illegal', $line, $pname);
		}
		if (isset($this->params[$pname])) return $this->params[$pname];

		// if (isset($this->dependencies[$pname])) {
		// 	foreach ($this->dependencies[$pname] as $dname) {
		// 		//if (isset($this->params[$pname])) continue;
		// 		$this->get($dname, $line);
		// 	}
		// 	if (isset($this->params[$pname])) return $this->params[$pname];
		// }
		$val = Ans::REQS($pname);

		//Повторяющиеся обработки на параметры

		if (is_null($val)) return $this->fail('required', __LINE__, $pname);

		$args = $this->meta['args'][$pname];
		if (in_array('notempty', $args)) {
			if (!$val && $val !== "0") return $this->fail('required', __LINE__, $pname);
		}
		if (in_array('int', $args)) {
			$val = (int) $val;
			if (strlen($val) > 100) return $this->fail('required', __LINE__, $pname);
		} else if (in_array('text', $args)) {
			$val = (string) $val;
			if (strlen($val) > 65000) return $this->fail('required', __LINE__, $pname);
		} else if (in_array('intarray', $args)) {
			if (strlen($val) > 65000) return $this->fail('required', __LINE__, $pname);
			if (!$val) return $this->fail('required', 'a' . __LINE__, $pname);
			$val = explode(',', $val);
			foreach ($val as $i => $id) {
				$val[$i] = (int) $id;
				if (!$val[$i]) return $this->fail('required', 'a' . __LINE__, $pname);
			}
			
		} else {
			$val = (string) $val;
			if (strlen($val) > 255) return $this->fail('required', __LINE__, $pname);
		}

		$this->params[$pname] = &$val;
		if (isset($this->args[$pname])) {	
			$this->exec($this->args[$pname], $pname, $this->params[$pname]);
		}
		return $this->params[$pname];
	}
	// public function vars($pnames, $line = __LINE__) {
	// 	$res = [];
	// 	foreach ($pnames as $pname) {
	// 		$res[$pname] = &$this->var($pname, $line);
	// 	}
	// 	return $res;
	// }
	public function exec($fn, $pname, &$val) {
		$func = \Closure::bind($fn, $this);
		return $func($val, $pname);
	}
	public function &var($pname, $line = __LINE__) {
		//Если параметра нет в списке нужных и это параметр из адресной строки - сообщаем об ошибки

		if (isset($this->params[$pname])) return $this->params[$pname];

		//required надо проверять
		//if (!in_array($pname, $this->actionmeta['vars'])) return $this->fail('required', $line, $pname);
		if (!isset($this->vars[$pname])) return $this->fail('illegal', $line, $pname);
		
		// if (isset($this->dependencies[$pname])) {
		// 	foreach ($this->dependencies[$pname] as $dname) {
		// 		//if (isset($this->params[$pname])) return $this->fail('recursion', $line, $pname);
		// 		$this->get($dname, $line);
		// 	}
		// 	if (isset($this->params[$pname])) return $this->params[$pname];
		// }
		if (!isset($this->vars[$pname])) return $this->fail('illegal', __LINE__, $pname);
		$this->params[$pname] = false;
		$this->exec($this->vars[$pname], $pname, $this->params[$pname]);
		return $this->params[$pname];
	}
	// public function getAll () {
	// 	return $this->gets($this->actionmeta['required'], 'm'.__LINE__);
	// }
	// public function handlers($pnames) {
	// 	$pnames = func_get_args();
	// 	return array_map([$this, 'handler'], $pnames);
	// }
	public function gets($pnames, $line = __LINE__) {
		foreach ($pnames as $pname) {
			$res[$pname] = &$this->get($pname, $line);
		}
		return $res;
	}
	public function &flag($pname, $line = __LINE__) {
		//Если параметра нет в списке нужных и это параметр из адресной строки - сообщаем об ошибки
		if (isset($this->params[$pname])) return $this->params[$pname];
		//required надо проверять
		if (!in_array($pname, $this->meta['flags'])) return $this->fail('illegal', $line, $pname);
		// if (isset($this->dependencies[$pname])) {
		// 	foreach ($this->dependencies[$pname] as $dname) {
		// 		$this->get($dname, $line);
		// 	}
		// 	if (isset($this->params[$pname])) return $this->params[$pname];
		// }
		$this->params[$pname] = in_array($pname, $this->actionmeta['flags'] ?? []);
		return $this->params[$pname];
	}
	public function &get($pname, $line = __LINE__) {
		if (isset($this->meta['args'][$pname])) {
			return $this->arg($pname, $line);
		} else if (in_array($pname, $this->meta['flags'])) {
			return $this->flag($pname, $line);
		} else if (in_array($pname, $this->meta['vars'])) {
			return $this->var($pname, $line);
		}
		else return $this->fail('illegal', $line, $pname);
	}
	public $ready = false;
	public function ret($code = false, $line = false, $pname = false) {
		extract($this->gets(['ans','lang'], __LINE__), EXTR_REFS);
		if ($this->ready) return $ans;
		$this->ready = true;
		if (!$code) {
			return Lang::ret($ans);
		}
		if (!$pname) {
			return Lang::ret($ans, $lang, $this->name.'.'.$code.'.'.$line);
		}
		$ans['payload'] = $pname;
		return Lang::rettpl($ans, $lang, $this->name.'.'.$code.'.'.$line);
	}
	public function err($code, $line, $pname = false) {
		extract($this->gets(['ans','lang'], __LINE__), EXTR_REFS);
		$ans['params'] = array_keys($this->params);
		if (!$pname) {
			$ans = Lang::err($ans, $lang, $this->name.'.'.$code.'.'.$line);
			throw new \Exception();
		} 
		$ans['missing'] = $pname;
		$ans = Lang::errtpl($ans, $lang, $this->name.'.'.$code.'.'.$line);
		throw new \Exception();
	}
	public function handler($hand, $line = __LINE__){
		if (empty($this->handlers[$hand])) return $this->fail('handler', $line, $hand);
		if (is_callable($this->handlers[$hand])) {
			$fn = \Closure::bind($this->handlers[$hand], $this);
			$this->handlers[$hand] = $fn();
		}
		return $this->handlers[$hand];
	}
}