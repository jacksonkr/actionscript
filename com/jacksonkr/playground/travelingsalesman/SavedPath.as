package com.jacksonkr.playground.travelingsalesman{
	public class SavedPath {
		private var _path_length:Number = 0;
		private var _cities:Vector.<City> = new Vector.<City>();
		
		public function SavedPath(cities:Vector.<City>) {
			for each(var c:City in cities) {
				_path_length += c.destinationLength;
				_cities.push(c.toObject(1));
			}
		}
		
		public function get cities():Vector.<City> {
			return _cities;
		}
		public function get length():Number {
			return Number(_path_length.toFixed(3));
		}
		public function getCityById(id:uint):City {
			for each(var c:City in _cities) {
				if(c.id == id) return c;
			}
			
			return null;
		}
	}
}