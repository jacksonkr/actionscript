package com.jacksonkr.playground.travelingsalesman{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Cities extends Sprite {
		public static const FINISHED_BATCH_SIZE:uint = 4;
		public const BATCHES_TIL_PARENT_RESET:uint = 15;
		
		public static const BATCH_COMPLETE:String = "batch_complete";
		public static const CITIES_PLACED:String = "cities_placed";
		public static const PATH_COMPLETE:String = "path_complete";
		
		private var _batch_count:uint = 0;
		private var _bestPath:Object;
		private var _cities:Vector.<City>;
		private var _city_count:uint = 8;
		private var _current_Batch:Vector.<SavedPath>;
		private var _last_Batch:Vector.<SavedPath>;
		private var _reference:Cities;
		
		public function Cities():void {
			reset();
		}
		
		private function batchCompleteHandler(event:Event):void {
			if(City.parents.batch_id <= _batch_count - BATCHES_TIL_PARENT_RESET) {
				trace('toss parents');
				City.setParents(this, null);
			}
			makeNewBatch();
		}
		private function citiesPlacedHandler(event:Event):void {
			_reference.countyStructure = _cities;
			
			makeNewBatch();
		}
		private function cityDestinationFoundHandler(event:Event):void {
			event.stopPropagation();
			
			event.target.destinationCity.findDestination();
		}
		private function makeNewBatch():void {
			if(!_current_Batch) _current_Batch = new Vector.<SavedPath>();
			
			makeNewPath();
		}
		private function makeNewPath():void {
			// shuffle the cities
			var tmp:Vector.<City> = _cities;
			_cities = new Vector.<City>();
			while(tmp.length) {
				var c:City = tmp.splice(Math.round(Math.random() * tmp.length - 1), 1)[0];
				_cities.push(c);
			}
			
			_cities[0].findDestination();
		}
		private function pathCompleteHandler(event:Event):void {
			// copies the cities with their current connections
			_current_Batch.push(new SavedPath(_cities));
			
			if(_current_Batch.length >= FINISHED_BATCH_SIZE) {
				// a set of batches is done.
				
				// sort current batch by shortes to longest
				var compare:Function = function(o1:Object, o2:Object):Number {
					if(o1.length < o2.length) {
						return -1;
					} else {
						return 1;
					}
					
					return 0;
				}
				_current_Batch.sort(compare);
				
				//_batches.push(_current_Batch);
				++_batch_count;
				_last_Batch = _current_Batch;
				
				City.decideParents(this);
				
				// display the best of this batch
				_reference.displayPath(City.parents.paths[0]);
				_current_Batch = new Vector.<SavedPath>();
				
				resetCities();
				
				dispatchEvent(new Event(BATCH_COMPLETE));
			} else {
				// this batch set ain't done yet!
				resetCities();
				
				makeNewPath();
			}
		}
		private function randomlyPlaceCities():void {
			_cities = new Vector.<City>();
			
			for(var i:uint = 0; i < _city_count; ++i) {
				var c:City = new City();
				_cities.push(c);
				c.id = i;
				addChildAt(c, 0);
			}
			
			dispatchEvent(new Event(CITIES_PLACED));
		}
		private function resetCities():void {
			for each(var city:City in _cities) {
				city.reset();
			}
		}
		
		public function get batchCount():uint {
			return _batch_count;
		}
		public function set cityCount(val:uint):void {
			_city_count = val;
		}
		public function set countyStructure(obj:Object):void {
			_cities = new Vector.<City>();
			
			for each(var city:City in obj) {
				var c:City = new City();
				c.copyCityInfo(city);
				_cities.push(c);
				addChildAt(c, 0);
			}
		}
		public function get currentBatch():Vector.<SavedPath> {
			return _current_Batch;
		}
		public function displayPath(obj:Object):uint {
			if(_bestPath) {
				if(_bestPath.length <= obj.length) {
					return 0;
				}
			}
			
			_bestPath = obj;
			
			resetCities();
			
			var route:String = "";
			
			for each(var c:City in _bestPath.cities) {
				var city:City;
				route += City.CITY_NAMES[c.id] + "->";
				
				loop: for(var i:uint = 0; i < numChildren; ++i) {
					if(c.name == getChildAt(i).name) {
						city = City(getChildAt(i));
						break loop;
					}
				}
				
				city.destinationCity = c.destinationCity;
			}
			
			Object(root).bestRouteTxt.text = route + route.substr(0, 1);
			Object(root).bestLengthTxt.text = _bestPath.length;
			
			return 0;
		}
		public function get endDestination():City {
			for each(var city:City in _cities) {
				if(!city.sourceCity) {
					return city;
				}
			}
			
			return null;
		}
		public function get lastBatch():Vector.<SavedPath> {
			return _last_Batch;
		}
		public function possibleDestinationCities(currentCity:City):Vector.<City> {
			var vector:Vector.<City> = new Vector.<City>;
			
			for each(var city:City in _cities) {
				if((city != currentCity) && !city.sourceCity && !city.destinationCity) {
					vector.push(city);
				}
			}
			
			return vector;
		}
		public function set reference(val:String):void {
			// this is basically the constructor. only because we don't want the "solution" group
			// to have all these listeners and then run. The solution is just supposed to sit pretty
			// and update based on the best solution. I could have used inhertance/polymorphism, but
			// lets face it, I was just havin' some fun.
			
			addEventListener(CITIES_PLACED, citiesPlacedHandler);
			addEventListener(BATCH_COMPLETE, batchCompleteHandler);
			addEventListener(PATH_COMPLETE, pathCompleteHandler);
			addEventListener(City.DESTINATION_FOUND, cityDestinationFoundHandler);
			
			_reference = Cities(parent[val]);
			
			randomlyPlaceCities();
		}
		public function reset():void {
			_batch_count = 0;
			if(_bestPath) _bestPath = null;
			if(_last_Batch) _last_Batch = new Vector.<SavedPath>();
			if(_current_Batch) _current_Batch = null;
			
			if(_cities) {
				while(_cities.length) {
					_cities.pop().destroy();
				}
			}
		}
		public function startOver():void {
			randomlyPlaceCities();
		}
	}
}