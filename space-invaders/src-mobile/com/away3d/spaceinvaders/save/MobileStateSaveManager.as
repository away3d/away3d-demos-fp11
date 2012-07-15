package com.away3d.spaceinvaders.save
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class MobileStateSaveManager extends StateSaveManager
	{
		private const FILE_PATH:String = "away3dSpaceInvadersUserData.txt";

		public function MobileStateSaveManager() {
			super();
		}

		override public function saveHighScore( score:uint ):void {
			trace( "saving score: " + score );
			var file:File = File.applicationStorageDirectory.resolvePath( FILE_PATH );
			var str:FileStream = new FileStream();
			str.open( file, FileMode.WRITE );
			str.position = 0;
			str.writeUnsignedInt( score );
		}

		override public function loadHighScore():uint {
			var file:File = File.applicationStorageDirectory.resolvePath( FILE_PATH );
			trace( "loading score - file exists: " + file.exists );
			if( file.exists ) {
				var str:FileStream = new FileStream();
				str.open( file, FileMode.READ );
				str.position = 0;
				return str.readUnsignedInt();
			}
			return 0;
		}
	}
}
