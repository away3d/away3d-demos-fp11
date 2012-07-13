package com.away3d.spaceinvaders.save
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class MobileStateSaveManager extends StateSaveManager
	{
		private const FILE_PATH:String = "away3dSpaceInvadersUserData.xml";

		public function MobileStateSaveManager() {
			super();
		}

		override public function saveHighScore( score:uint ):void {
			trace( "saving score: " + score );
			var file:File = File.applicationStorageDirectory.resolvePath( FILE_PATH );
			trace( "file: " + file );
			var str:FileStream = new FileStream();
			str.open( file, FileMode.WRITE );
			str.position = 0;
			var xml:XML = <xml><score>score</score></xml>;
			trace( "xml: " + xml );
			str.writeUTFBytes( xml );
		}

		override public function loadHighScore():uint {
			var file:File = File.applicationStorageDirectory.resolvePath( FILE_PATH );
			trace( "loading score - file exists: " + file.exists );
			if( file.exists ) {
				var str:FileStream = new FileStream();
				str.open( file, FileMode.READ );
				str.position = 0;
				var xml:XML = new XML( str.readUTFBytes( str.bytesAvailable ) );
				trace( "xml: " + xml );
				var score:uint = uint( xml.score[ 0 ].toString() );
				trace( "read score: " + score );
				return score;
			}
			return 0;
		}
	}
}
