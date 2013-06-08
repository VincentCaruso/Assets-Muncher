package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Tiffus mailto : el.tiffus@gmail.com ^^
	 */
	public class MiniForm extends Sprite
	{
		private var _formName:String;
		private var _response:TextField;
		
		public function MiniForm(formName:String)
		{
			this._formName = formName;
			
			_init();
		
		}
		
		private function _init():void
		{
			const FORM_WIDTH:int = 195;
			const FORM_HEIGHT:int = 20;
			
			var tf:TextField = new TextField();
			tf.width = FORM_WIDTH;
			tf.height = FORM_HEIGHT;
			tf.multiline = false;
			tf.defaultTextFormat = new TextFormat(null, null, null, null, null, null, null, null, TextFormatAlign.CENTER);
			tf.text = _formName;
			tf.backgroundColor = 0xDDDDDD;
			tf.background = true;
			addChild(tf);
			
			_response = new TextField();
			_response.width = FORM_WIDTH;
			_response.height = FORM_HEIGHT;
			_response.multiline = false;
			_response.border = true;
			_response.type = TextFieldType.INPUT;
			_response.y = tf.height;
			
			addChild(_response);
		}
		
		public function get text():String
		{
			return _response.text;
		}
	
	}

}