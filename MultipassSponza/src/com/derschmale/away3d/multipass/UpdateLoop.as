package com.derschmale.away3d.multipass
{
	import com.derschmale.patterns.commands.Command;

	import flash.display.Stage;
	import flash.events.Event;

	public class UpdateLoop
	{
		private var _stage:Stage;
		private var _commands:Vector.<Command>;

		public function UpdateLoop(stage : Stage)
		{
			_stage = stage;
			_commands = new Vector.<Command>();
		}

		public function addCommand(command : Command) : void
		{
			_commands.push(command);
		}

		public function removeCommand(command : Command) : void
		{
			_commands.splice(_commands.indexOf(command), 1);
		}

		public function start() : void
		{
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function stop() : void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event:Event):void
		{
			var numCommands : int = _commands.length;
			for (var i : int = 0; i < numCommands; ++i)
			    _commands[i].execute();
		}
	}
}
