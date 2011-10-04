package com.jacksonkr.playground.travelingsalesman{
	import fl.controls.Slider;
	import flash.display.Sprite;
	import flash.events.Event;
	//import flash.utils.setTimeout;
	import flash.utils.getTimer;
	
	public class City extends Sprite {
		public static const CITY_NAMES:Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"];
		public const SPREAD:Number = 100.0;
		
		public static const DESTINATION_FOUND:String = "destination_found";
		
		private var _sourceCity:City;
		private var _destinationCity:City;
		private var _id:uint;
		private var _last_connection:Boolean = false;
		private var _lines:Sprite;
		private static var _parents:Object;
		private var _timer_stamp:Number;
		
		public function City():void {
			addChildAt(_lines = new Sprite(), 0);
			reset();
		}
		
		private function enterFrameHandler(event:Event):void {
			if((_timer_stamp + Object(root).speedSlider.value < getTimer())) {
				if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				if(_last_connection) {
					_last_connection = false;
					parent.dispatchEvent(new Event(Cities.PATH_COMPLETE));
				} else {
					dispatchEvent(new Event(DESTINATION_FOUND, true));
				}
			}
		}
		
		public function findDestination():void {
			var possible_Destinations:Vector.<City> = Cities(parent).possibleDestinationCities(this);
			
			if(possible_Destinations.length) {
				/*/ half the current batch is random pieces of the parents
				// other half is random
				if(City.parents && (Cities(parent).currentBatch.length <= Math.ceil(Cities.FINISHED_BATCH_SIZE / 2))) {
					var parent_id = Math.round(Math.random());
					loop: for each(var c:City in possible_Destinations) {
						if(c.id == City.parents.paths[parent_id].getCityById(id).destinationCity.id) {
							destinationCity = c;
							break loop;
						}
					}
				}
				/*/
				
				
				// starts out using random pieces
				// more and more parent genes are added per run
				var batch_complete_perc = (Cities(parent).currentBatch.length + 1) / Cities.FINISHED_BATCH_SIZE;
				if(City.parents && (id <= Cities.FINISHED_BATCH_SIZE * batch_complete_perc)) {
					var parent_id = Math.round(Math.random());
					loop: for each(var c:City in possible_Destinations) {
						if(c.id == City.parents.paths[parent_id].getCityById(id).destinationCity.id) {
							destinationCity = c;
							break loop;
						}
					}
				}
				//
				
				// incase the above statement doesn't find a suitable 
				// destination city, just use a random one.
				if(!destinationCity) {
					destinationCity = possible_Destinations[0];
				}
			} else {
				_last_connection = true;
				destinationCity = Cities(parent).endDestination;
			}
			
			destinationCity.sourceCity = this;
			
			_timer_stamp = getTimer();
			
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		public function get id():uint {
			return _id;
		}
		public function set id(val:uint):void {
			_id = val;
			
			name = "city_" + CITY_NAMES[_id];
			nameTxt.text = CITY_NAMES[_id];
			x = Math.random() * (SPREAD * 2) - SPREAD;
			y = Math.random() * (SPREAD * 2) - SPREAD;
		}
		public function copyCityInfo(obj:City):void {
			id = obj.id;
			x = obj.x;
			y = obj.y;
		}
		public static function decideParents(citiesPtr:Cities):void {
			if(parents) {
				if(citiesPtr.lastBatch[0].length < parents.paths[0].length) {
					_parents.paths[0] = citiesPtr.lastBatch[0];
					
					if(citiesPtr.lastBatch[1].length < parents.paths[1].length) {
						_parents.paths[1] = citiesPtr.lastBatch[1];
					}
				} else if(citiesPtr.lastBatch[0].length < parents.paths[1].length) {
					_parents.paths[1] = citiesPtr.lastBatch[0];
				}
			} else {
				var p:Vector.<Object> = new Vector.<Object>(2, true);
				p[0] = citiesPtr.lastBatch[0];
				p[1] = citiesPtr.lastBatch[1];
				setParents(citiesPtr, p);
			}
		}
		public function get destinationCity():City {
			return _destinationCity;
		}
		public function set destinationCity(city:City):void {
			_destinationCity = city;
			
			_lines.graphics.moveTo(0, 0);
			_lines.graphics.lineTo(_destinationCity.x - x, _destinationCity.y - y);
		}
		public function get destinationLength():Number {
			var d = _destinationCity;
			return Math.sqrt(Math.pow(d.x - x, 2) + Math.pow(d.y - y, 2));
		}
		public function destroy():void {
			_parents = null;
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			removeChild(_lines);
			_lines = null;
			parent.removeChild(this);
		}
		public static function get parents():Object {
			return _parents;
		}
		public static function setParents(citiesPtr:Cities, obj:Vector.<Object>):void {
			if(!obj) {
				_parents = undefined;
			} else {
				_parents = {batch_id:citiesPtr.batchCount, paths:obj};
			}
		}
		public function reset():void {
			_sourceCity = null;
			_destinationCity = null;
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_lines.graphics.clear();
			_lines.graphics.lineStyle(2.0, 0x333333);
		}
		public function get sourceCity():City {
			return _sourceCity;
		}
		public function set sourceCity(city:City):void {
			_sourceCity = city;
		}
		public function toObject(level:uint=0):City {
			var obj:City = new City();
			obj.name = name;
			obj.id = _id;
			obj.x = x;
			obj.y = y;
			
			if(level > 0) {
				if(!_destinationCity) throw new Error("missing destinationCity");
				if(!_sourceCity) throw new Error("missing sourceCity");
				
				obj.destinationCity = _destinationCity.toObject();
				obj.sourceCity = _sourceCity.toObject();
			}
			
			return obj;
		}
	}
}