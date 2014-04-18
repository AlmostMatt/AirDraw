package airdraw.Utils 
{
	import flash.display.Graphics;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Utils 
	{
		//utility function
		public static function dottedLine(g:Graphics, x1:Number, y1:Number, x2:Number, y2:Number,dot:Number=5,gap:Number=10):void
		{
			g.moveTo(x1, y1);
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			var d:Number = Math.sqrt(dx * dx + dy * dy);
			if (d == 0) return;
			
			var partiald:Number = 0; 
			//var dremaining:Number = d;
			var lining:Boolean = true;
			var size:Number = dot;
			while (partiald + size < d)
			{
				if (lining)
					g.lineTo(x1 + dx * (partiald + size)/d, y1 + dy * (partiald + size)/d);
				else
					g.moveTo(x1 + dx * (partiald + size)/d, y1 + dy * (partiald + size)/d);
				partiald += size;
				lining = !lining;
				size = (dot + gap) - size; //toggle between the two
				//dot = l;
			}
			//part of line that is being drawn right now is less than portion of dot remaining 
			if (lining)
				g.lineTo(x2,y2);
			else
				g.moveTo(x2,y2);
			//dot -= dremaining;
		}
		
		//alternative set of functions:
		//rgb->color
		//hsv->color
		//color->h
		//color->s
		//color->v
		
		//returns a 3 tuple array of [uint, Number, Number]
		//converts red green blue to hue saturation value
		public static function rgb2hsv(r:uint, g:uint, b:uint):Array
		{
			var M:uint = Math.max(r, g, b), m:uint = Math.min(r, g, b);
			var C:Number = M - m; //forcing floating point number after division
			var H:Number;
			if (C == 0)
				H = 0;
			else if (M == r)
				H = Mod((g - b) / C,6);
			else if (M == g)
				H = (b - r) / C + 2;
			else if (M == b)
				H = (r - g) / C + 4;			
			var h:uint = 60 * H;
			
			//v = (r+g+b)/(3*255)
			var v:Number = M / 255;// (r + g + b) / (3 * 255)
			var s:Number;
			if (C == 0)
				s = 0;
			else
				s = C / (v * 255);
			return [h, s, v];
		}
		//returns a 3 tuple array of [uint, uint, uint]
		//converts to red green blue from hue saturation value
		public static function hsv2rgb (h:uint, s:Number, v:Number):Array
		{
			//http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
			var C:Number = s * v; //chroma
			var H:Number = h / 60; //hue with respect to sections of a hexagon
			var X:Number = C * (1 - Math.abs(Mod(H,2) - 1))
			var r1:Number=0, g1:Number=0, b1:Number=0;
			if (H < 1)
				r1 = C, g1 = X;
			else if (H < 2)
				r1 = X, g1 = C;
			else if (H < 3)
				g1 = C, b1 = X;
			else if (H < 4)
				g1 = X, b1 = C;
			else if (H < 5)
				r1 = X, b1 = C;
			else
				r1 = C, b1 = X;
			var m:Number = v - C;
			//return [r, g, b];
			return [255 * (r1 + m), 255 * (g1 + m), 255 * (b1 + m)];		
		}
		
		//combine r g and b to a uint
		public static function rgbColor(r:uint, g:uint, b:uint):uint
		{
			return ( ( r << 16 ) | ( g << 8 ) | b ); //(a << 24) | 
		}
		//combine h s and v to a uint
		public static function hsvColor(h:uint, s:Number, v:Number):uint
		{
			var rgb:Array = hsv2rgb(h, s, v);
			return ( ( rgb[0] << 16 ) | ( rgb[1] << 8 ) | rgb[2] ); //(a << 24) | 
		}
		
		//convert a color to an r g b tuple
		public static function getRGB(col:uint):Array
		{
			var r:uint = (col & 0xff0000) >> 16;
			var g:uint = (col & 0x00ff00) >> 8;
			var b:uint = col & 0xff;
			return [r, g, b];
		}
		//convert a color to an h s v tuple
		public static function getHSV(col:uint):Array
		{
			var r:uint = (col & 0xff0000) >> 16;
			var g:uint = (col & 0x00ff00) >> 8;
			var b:uint = col & 0xff;
			return rgb2hsv(r,g,b);
		}
		
		//helper f
		//not sure % works for decimals
		private static function Mod(num:Number, base:Number):Number
		{
			while (num > base) num = num - base;
			while (num < 0) num = num + base;
			return num
		}
		
		//returns the angle difference in degrees within the range -180 to 180
		public static function angleDiff(a1:Number, a2:Number):Number
		{
			var diff:Number = a1 - a2;
			if (diff < -180) diff += 360;
			if (diff > 180) diff -= 360;
			return diff;
		}
		
		//draws an arc of arcsize and radius starting at startangle.
		//angless given in radians
		public static function drawArc(graphicObj:Graphics, cx:Number, cy:Number, radius:Number, startAngle:Number = 0, arcAngle:Number = Math.PI, closed:Boolean = false, steps:int = 16):void
		{
			var angleStep:Number = -arcAngle / steps;//transformation matrix is clockwise while numeric angle increase is ccw I think
			var cosa:Number = Math.cos(angleStep);
			var sina:Number = Math.sin(angleStep);
			var prevx:Number = Math.cos(startAngle) * radius;
			var prevy:Number = Math.sin(startAngle) * radius;
			if (closed) {
				graphicObj.moveTo(cx, cy);
				graphicObj.lineTo(cx + prevx, cy + prevy);
			} else
				graphicObj.moveTo(cx + prevx, cy + prevy);
			for(var i:int=1; i<=steps; i++){
				//rotation matrix for 2d point around 0 is newx = x cos + y sin, newy = - x sin +y cos
				var nextx:Number = cosa * prevx + sina * prevy;
				var nexty:Number = - sina * prevx + cosa * prevy;
				graphicObj.lineTo(cx + nextx, cy + nexty);
				prevx = nextx;
				prevy = nexty;
			}
			if (closed) {
				graphicObj.lineTo(cx, cy);
			}
		}
		
		//draws two arcs of different radii and arcsize centered on a common angle
		//and fills the area in between
		//or rather, it draws it as a closed polygon so that if a beginFill is in effect it will fill the shape
		public static function fillArcs(graphicObj:Graphics, cx:Number, cy:Number, radius1:Number, radius2:Number, angle:Number = 0, arcAngle1:Number = Math.PI, arcAngle2:Number = Math.PI, steps:int = 16):void
		{
			//get the cosine and sine of a single angle segment to create transformation matrix for rotation
			var angleStep:Number = -arcAngle1 / steps;
			var cosa:Number = Math.cos(angleStep);
			var sina:Number = Math.sin(angleStep);
			
			var prevx:Number = Math.cos(angle - arcAngle1/2) * radius1;
			var prevy:Number = Math.sin(angle - arcAngle1/2) * radius1;
			
			graphicObj.moveTo(cx + prevx, cy + prevy);
			for(var i:int=1; i<=steps; i++){
				//rotation matrix for 2d point around 0 is newx = x cos + y sin, newy = - x sin +y cos
				var nextx:Number = cosa * prevx + sina * prevy;
				var nexty:Number = - sina * prevx + cosa * prevy;
				graphicObj.lineTo(cx + nextx, cy + nexty);
				prevx = nextx;
				prevy = nexty;
			}
			//draw the second arc in the reverse order
			//so use a negative angle step
			angleStep = arcAngle2 / steps;
			cosa = Math.cos(angleStep);
			sina = Math.sin(angleStep);
			
			prevx = Math.cos(angle + arcAngle2 / 2) * radius2;
			prevy = Math.sin(angle + arcAngle2 / 2) * radius2;
			//draw the line from end of prev arc to start of this arc
			graphicObj.lineTo(cx + prevx, cy + prevy);
			for(i=1; i<=steps; i++){
				//rotation matrix for around 0 is newx = x cos + y sin, newy = - x sin +y cos
				nextx = cosa * prevx + sina * prevy;
				nexty = - sina * prevx + cosa * prevy;
				graphicObj.lineTo(cx + nextx, cy + nexty);
				prevx = nextx;
				prevy = nexty;
			}
			//close the shape by drawing a line to the start point
			graphicObj.lineTo(cx + prevx, cy + prevy);			
		}
	}

}