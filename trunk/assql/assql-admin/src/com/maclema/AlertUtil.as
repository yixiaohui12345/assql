package com.maclema
{
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.mx_internal;
	import mx.managers.PopUpManager;
	
	use namespace mx_internal;
	
	public class AlertUtil
	{
		private static var theAlert:Alert;
		private static var hideTimeMin:Number;
		
		public static function showAlert(message:String, title:String, minShowTime:Number=0):void {
			hideAlert(false);		
			
			hideTimeMin = getTimer()+minShowTime;
				
			theAlert = Alert.show(message, title, Alert.OK);
			theAlert.mx_internal::alertForm.mx_internal::buttons[0].enabled = false;
			theAlert.mx_internal::alertForm.removeChild(theAlert.mx_internal::alertForm.mx_internal::buttons[0]);
		}
		
		public static function hideAlert(timeCheck:Boolean=true):void {
			if ( theAlert == null ) {
				return;
			}
			
			if ( timeCheck ) {
				var time:Number = getTimer();
				if ( time < hideTimeMin ) {
					var diff:Number = (hideTimeMin-time)+10;
					setTimeout(hideAlert, diff);
					return;
				}
			}
			
			PopUpManager.removePopUp(theAlert);
			theAlert = null;
		}
	}
}