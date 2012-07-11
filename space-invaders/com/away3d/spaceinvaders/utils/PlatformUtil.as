package com.away3d.spaceinvaders.utils
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	public class PlatformUtil
	{
		public static function isRunningOnMobile():Boolean {
			var runningOnMobile:Boolean = checkBrowser() == "none" ;
			trace( "runningOnMobile: " + runningOnMobile );
			return runningOnMobile;
		}

		public static function checkBrowser():String {
			var browser:String = "none";
			try {
				var strUserAgent:String = String( ExternalInterface.call( "function() {return navigator.userAgent;}" ) ).toLowerCase();
				if( strUserAgent.indexOf( "firefox" ) != -1 ) {
					browser = "Firefox";
				}
				else if( strUserAgent.indexOf( "msie" ) != -1 ) {
					browser = "Internet Explorer";
				}
				else if( strUserAgent.indexOf( "safari" ) != -1 ) {
					browser = "Safari";
				}
				else if( strUserAgent.indexOf( "chrome" ) != -1 ) {
					browser = "Google Chrome";
				}
				else if( strUserAgent.indexOf( "opera" ) != -1 ) {
					browser = "Opera";
				}
			} catch( e:Error ) {
			}
			trace( "browser: " + browser );
			return browser
		}
	}
}