package pages.index;

import stdlib.Regex;
using StringTools;

class Client extends BaseClient
{
	function init()
	{
		untyped __js__("
			var textareas = document.getElementsByTagName('textarea');
			var count = textareas.length;
			for(var i=0;i<count;i++){
				textareas[i].onkeydown = function(e){
					if(e.keyCode==9 || e.which==9){
						e.preventDefault();
						var s = this.selectionStart;
						this.value = this.value.substring(0,this.selectionStart) + '\t' + this.value.substring(this.selectionEnd);
						this.selectionEnd = s+1; 
					}
				}
			}
		");
	}
	
	function run_click(_, _)
	{
		var result = try getResult() catch (e:Dynamic) Std.string(e);
		template().result.val(result);
	}
	
	function getResult() : String
	{
		var rules = getRules(template().re.val());
		var text = template().text.val().replace("\r\n", "\n").replace("\r", "\n");
		for (rule in rules)
		{
			text = rule.replace(text);
		}
		return text;
	}
	
	static function getRules(content:String) : Array<Regex>
	{
		var rules = [];
		
		var lines = content.replace("\r\n", "\n").replace("\r", "\n").split("\n");
		var consts = new Array<{ name:String, value:String }>();
		for (line in lines)
		{
			line = line.trim();
			
			if (line == "" || line.startsWith("//")) continue;
			
			var reConst = ~/^([_a-zA-Z][_a-zA-Z0-9]*)\s*[=]\s*(.+?)$/;
			
			if (reConst.match(line))
			{
				var value = reConst.matched(2);
				for (const in consts)
				{
					value = replaceWord(value, const.name, const.value);
				}
				consts.push({ name:reConst.matched(1), value:value });
			}
			else
			{
				for (const in consts)
				{
					line = replaceWord(line, const.name, const.value);
				}
				rules.push(new Regex(line));
			}
		}
		
		return rules;
	}
	
	
	static function replaceWord(src:String, search:String, replacement:String) : String
	{
		return new EReg("(^|[^_a-zA-Z0-9])" + search + "($|[^_a-zA-Z0-9])", "g").map(src, function(re)
		{
			return re.matched(1) + replacement + re.matched(2);
		});
	}
}