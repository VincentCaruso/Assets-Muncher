package
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Main extends Sprite
	{
		private var _dropTarget:Sprite = new Sprite();
		private var _fullListing:Vector.<File>;
		private var _rootNativePath:String;
		
		//LOG
		private var _log:TextField = new TextField();
		
		//FORMS
		private var _classNameTF:MiniForm;
		private var _packageTF:MiniForm;
		private var _prependTF:MiniForm;
		
		public function Main()
		{
			addEventListener(Event.ADDED_TO_STAGE, doStage);
		}
		
		private function doStage(e:Event):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//Log
			_log.autoSize = TextFieldAutoSize.LEFT;
			_log.width = 600;
			_log.x = 200;
			_log.appendText("I'm starving, feed me ! Drop your file or folder here\n");
			addChild(_log);
			
			//Drop target
			_dropTarget.graphics.beginFill(0x0000ff);
			_dropTarget.graphics.drawRect(0, 0, 600, 800);
			_dropTarget.x = 200;
			_dropTarget.alpha = 0;
			addChild(_dropTarget);
			
			//Class name;
			_classNameTF = new MiniForm("Class Name");
			addChild(_classNameTF);
			
			//Package;
			_packageTF = new MiniForm("Package");
			_packageTF.y = _classNameTF.y + _classNameTF.height + 20;
			addChild(_packageTF);
			
			//Package;
			_prependTF = new MiniForm("Prepend ex : ../../");
			_prependTF.y = _packageTF.y + _packageTF.height + 20;
			addChild(_prependTF);
			
			//Events
			_dropTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, doDragEnter);
			_dropTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, doDragDrop);
			_dropTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, doDragExit);
		}
		
		///////////////////////////////////////
		// MANAGE DROP
		///////////////////////////////////////
		
		private function doDragEnter(e:NativeDragEvent):void
		{
			NativeDragManager.acceptDragDrop(_dropTarget);
			
			_dropTarget.alpha = 0.2;
		}
		
		private function doDragExit(e:NativeDragEvent):void
		{
			
			_dropTarget.alpha = 0;
		}
		
		private function doDragDrop(e:NativeDragEvent):void
		{
			_fullListing = new Vector.<File>;
			
			//The files dropped
			var dropFiles:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			//Get the root path of the files dropped
			_rootNativePath = (dropFiles[0] as File).nativePath;
			_rootNativePath = _rootNativePath.split((dropFiles[0] as File).name)[0];
			
			//get files in directory and subdirectories
			getFullListing(dropFiles);
			_fullListing.fixed = true;
			
			//Make the final file
			_makeFile();
		
		}
		
		/**
		 * Recursive function for getting all the files in subfolders
		 * @param	aDrop
		 */
		private function getFullListing(aDrop:Array):void
		{
			for each (var file:File in aDrop)
			{
				if (file.isDirectory)
				{
					getFullListing(file.getDirectoryListing());
				}
				else
				{
					_fullListing.push(file);
				}
			}
		}
		
		///////////////////////////////////////
		// MAKE FILE
		///////////////////////////////////////
		private function _makeFile():void
		{
			_log.appendText("MUNCH MUNCH !\n");
			
			var txt:String = new String();
			var pattern:RegExp = /\\/g;
			var rootRelativePath:String = new String();
			var className:String = _classNameTF.text == "" ? "EmbededAssets" : _classNameTF.text;
			var prepend:String = _prependTF.text;
			
			txt += "package " + _packageTF.text + "\n{\n"
			txt += "\tpublic class " + className + "\n";
			txt += "\t{\n";
			
			for each (var file:File in _fullListing)
			{
				//Don't mind the json and pex
				if (file.extension == "json" || file.extension == "pex")
				{
					_log.appendText(file.extension.toUpperCase() + " is not compatible with Starling AssetsManager, " + file.name + " excluded\n");
				}
				else
				{
					rootRelativePath = file.nativePath.split(_rootNativePath)[1];
					rootRelativePath = rootRelativePath.replace(pattern, "/");
					
					if (file.extension == "xml" || file.extension == "fnt")
					{
						txt += "\t\t[Embed(source=\"" + prepend + rootRelativePath + "\", mimeType=\"application/octet-stream\")] ";
					}
					else
					{
						txt += "\t\t[Embed(source=\"" + prepend + rootRelativePath + "\")] ";
					}
					txt += "\n\t\tpublic static const " + file.name.split(".")[0] + "_" + file.extension + ":Class;\n\n";
				}
			}
			txt += "\t}\n";
			txt += "}";
			
			//Save the file
			var fileRef:FileReference;
			fileRef = new FileReference();
			fileRef.save(txt, className + ".as");
			
			_log.appendText("FINISH !\n");
		
		}
	}
}